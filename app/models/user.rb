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

  attr_accessible :country, :email, :first_name, :last_name, :news, 
                  :password_digest, :password, :password_confirmation, :phone, 
                  :street, :town, :zip_code, :preferred_language

  has_secure_password

  before_save {|user| user.email = email.downcase}
  before_save :create_remember_token

#  before_create { generate_token(:auth_token) }

  validates :first_name, :last_name, :street, :zip_code, :town, :country, :phone, presence: true
  
  EMAIL_PATTERN = /\A[\w!#\$%&'*+\/=?`{|}~^-]+(?:\.[\w!#\$%&'*+\/=?`{|}~^-]+)*@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}\Z/

  validates :email, presence: true, format: {with: EMAIL_PATTERN}, uniqueness: {case_sensitive: false}

  validates :password, length: {minimum: 6}
  validates :password_confirmation, presence: true

  def self.subscribers(language = LANGUAGES.map { |language, code| code })
    select(:email).
      where(news: true, preferred_language: language).
      map { |user| user.email }
  end

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
      find(:all, conditions: ['first_name LIKE ? or last_name LIKE ?', 
           "%#{search}%", "%#{search}%"])
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

  def address_labels_as_pdf(params)
    count = params[:count] || 20
    labels_per_page = params[:labels_per_page] || 20
    labels_per_row  = params[:labels_per_row]  || 2

    pdf = Prawn::Document.new(page_size: "A4")
    page_height = pdf.bounds.height
    label_height = page_height / (labels_per_page / labels_per_row)
    label_width  = pdf.bounds.width / labels_per_row
    pages = ((count / labels_per_page) + 
             (0.5 * (count % labels_per_page) > 0 ? 1 : 0)).round

    pdf.repeat(:all) do
      pdf.number_pages I18n.t('.labels_print_note'),
                       { at: [pdf.bounds.left, pdf.bounds.top + 15],
                         align: :center,
                         size: 10 }
    end

    print_index = 0

    1.upto(pages) do |page|
      page_height.step(label_height, -label_height) do |y|
        0.step(label_width, label_width) do |x|
          pdf.bounding_box([x,y], width: label_width, height: label_height) do
            pdf.dash(2, space: 2, phase: 0)
            pdf.transparent(0.5) { pdf.stroke_bounds }
            
            pdf.bounding_box([10, pdf.cursor - 10], 
                             width: label_width - 2 * 10,
                             height: label_height - 2 * 10) do
              pdf.text("#{first_name} #{last_name}")
              pdf.text("#{zip_code} #{town}")
              pdf.text("#{phone}")
            end
          end
          print_index += 1 
          break if print_index > count - 1
        end
        break if print_index > count - 1
      end
      pdf.start_new_page if page < pages 
    end
    pdf.render
  end

  private

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end

end
