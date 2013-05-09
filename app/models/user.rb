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
  attr_accessible :country, :email, :first_name, :last_name, :news, :password_digest, :password, :password_confirmation, :phone, :street, :town, :zip_code

  has_secure_password

  before_save {|user| user.email = email.downcase}
  before_save :create_remember_token

  validates :first_name, :last_name, :street, :zip_code, :town, :country, :phone, presence: true
  
  EMAIL_PATTERN = /\A[\w!#\$%&'*+\/=?`{|}~^-]+(?:\.[\w!#\$%&'*+\/=?`{|}~^-]+)*@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}\Z/

  validates :email, presence: true, format: {with: EMAIL_PATTERN}, uniqueness: {case_sensitive: false}

  validates :password, presence: true, length: {minimum: 6}
  validates :password_confirmation, presence: true

  private

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end

end
