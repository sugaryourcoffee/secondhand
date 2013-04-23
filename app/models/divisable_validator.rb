# Validates whether the value is divisable by the provided divisor.
#     validates :price, dividable: {divisor: 0.5}
# Checks whether the price is divisible by 50 cent without remainder
class DivisableValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << (
      options[:message] || "has to be divisable by #{options[:divisor]}"
    ) unless
      not value.nil? and value % options[:divisor] == 0
  end
end
