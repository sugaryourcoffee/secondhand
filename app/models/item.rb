class Item < ActiveRecord::Base
  belongs_to :list
  belongs_to :selling
  belongs_to :cart

  attr_accessible :description, :item_number, :price, :size

  scope :by_item_number, order(:item_number)

  validates :list_id, :description, :price, presence: true
  validates :item_number, numericality: { greater_than_or_equal_to: 1 }
  validates :price, numericality: { greater_than_or_equal_to: 0.5 }
  validates :price, divisable: { divisor: 0.5 }

  before_validation :delocalize_number
  before_validation :add_item_number

  before_save :reset_list_sent_on

  before_destroy :reset_list_sent_on

  def sold?
    !selling_id.nil?
  end

  def in_cart?
    !cart_id.nil?
  end

  private

  def delocalize_number
    return if price_before_type_cast.nil?
    self[:price] = price_before_type_cast.to_s.tr(',','.') if I18n.locale == :de
  end

  def add_item_number
    return if list_id.nil?
    self.item_number = List.find(list_id).next_item_number unless item_number
  end

  def reset_list_sent_on
    if list.sent_on
      list.sent_on = nil
      list.save
    end
  end

end
