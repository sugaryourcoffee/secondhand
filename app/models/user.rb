# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  first_name      :string(255)
#  last_name       :string(255)
#  street          :string(255)
#  zip_code        :string(255)
#  town            :string(255)
#  country         :string(255)
#  phone           :string(255)
#  email           :string(255)
#  password_digest :string(255)
#  news            :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ActiveRecord::Base
  has_many :lists

  attr_accessible :country, :email, :first_name, :last_name, :news, :password_digest, :password, :password_confirmation, :phone, :street, :town, :zip_code

  has_secure_password

  before_save {|user| user.email = email.downcase}
  before_save :create_remember_token

#  before_create { generate_token(:auth_token) }

  validates :first_name, :last_name, :street, :zip_code, :town, :country, :phone, presence: true
  
  EMAIL_PATTERN = /\A[\w!#\$%&'*+\/=?`{|}~^-]+(?:\.[\w!#\$%&'*+\/=?`{|}~^-]+)*@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}\Z/

  validates :email, presence: true, format: {with: EMAIL_PATTERN}, uniqueness: {case_sensitive: false}

  validates :password, length: {minimum: 6}
  validates :password_confirmation, presence: true

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    self.password = :password_reset_token
    self.password_confirmation = :password_reset_token
    save!
    UserMailer.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def lists_for_active_event
    event = Event.find_by_active(true)
    List.where(user_id: id, event_id: event).order(:list_number)
  end

  def self.search(search)
    if search
      find(:all, conditions: ['first_name LIKE ? or last_name LIKE ?', "%#{search}%", "%#{search}%"])
    else
      find(:all)
    end 
  end

  def self.search_conditions(params)
    if params[:search]
      ['first_name LIKE ? or last_name LIKE ?', 
       "%#{params[:search]}%", "%#{params[:search]}%"]
    else
      search_params = params.select { |k,v| not v.empty? and k =~ /^search_/ }
      unless search_params.empty?
        query_string = ""
        values       = []
        first_value  = true
        search_params.each do |k,v|
          if first_value
            first_value = false
          else
            query_string << " and "
          end

          key = k.sub("search_", "")

          if key == "news"
            query_string << "#{key} = ?" if v == "on"
            values << true 
          else
            query_string << "#{key} LIKE ?"
            values << "%#{v}%"
          end
        end
        [query_string, values].flatten
      else
        nil
      end
    end
  end

  private

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end

end
