class Message
  include ActiveModel::Validations
  include ActiveModel::Conversion
  
  attr_accessor :attributes

  validates :subject, :category, :message, presence: true

  EMAIL_PATTERN = /\A[\w!#\$%&'*+\/=?`{|}~^-]+(?:\.[\w!#\$%&'*+\/=?`{|}~^-]+)*@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}\Z/

  validates :email, presence: true, format: {with: EMAIL_PATTERN}

  def method_missing(m, *args, &block)
    attribute = @attributes[m]
    return attribute unless attribute.nil?
    super
  end

  def initialize(attributes = {})
    @attributes = attributes
  end

  def read_attribute_for_validation(key)
    @attributes[key]
  end

  def persisted?
    false
  end
end
