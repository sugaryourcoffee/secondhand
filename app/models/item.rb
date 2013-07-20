class Item < ActiveRecord::Base
  belongs_to :list

  attr_accessible :description, :item_number, :price, :size

  validates :list_id, :description, :price, presence: true
  validates :item_number, numericality: { greater_than_or_equal_to: 1 }
  validates :price, numericality: { greater_than_or_equal_to: 0.5 }
  validates :price, divisable: { divisor: 0.5 }

  before_validation :delocalize_number
  before_validation :add_item_number

  private

  def delocalize_number
    return if price_before_type_cast.nil?
    self[:price] = price_before_type_cast.to_s.tr(',','.') if I18n.locale == :de
  end

  def add_item_number
    return if list_id.nil?
    self.item_number = List.find(list_id).next_item_number unless item_number
  end
end
