class Item < ActiveRecord::Base
  belongs_to :list
  has_many :line_items
  has_many :sellings,  through: :line_items
  has_many :reversals, through: :line_items
  has_many :carts,     through: :line_items
  
#  attr_accessible :description, :item_number, :price, :size

  scope :by_item_number, -> { order(:item_number) }

  validates :list_id, :description, :price, presence: true
  validates :item_number, numericality: { greater_than_or_equal_to: 1 }
  validates :price, numericality: { greater_than_or_equal_to: 0.5 }
  validates :price, divisable: { divisor: 0.5 }

  before_validation :delocalize_number
  before_validation :add_item_number

  before_save :ensure_not_in_accepted_list
  before_save :ensure_not_in_cart
  before_save :ensure_not_sold
  before_save :reset_list_sent_on

  before_destroy :ensure_not_referenced, :reset_list_sent_on

  def sold?
    line_items.
      where('selling_id is not ? and reversal_id is ?', nil, nil).size > 0
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

  def ensure_not_referenced
    if line_items.empty?
      true
    else
      errors.add(:item, "Cannot delete referenced item")
      false
    end
  end

  def ensure_not_in_accepted_list
    if list.accepted_on
      errors.add(:item, "Cannot change item of accepted list")
      false
    else
      true
    end
  end
  
  def ensure_not_in_cart
    if carts.empty?
      true
    else
      errors.add(:item, "Cannot change item when in cart")
      false
    end
  end

  def ensure_not_sold
    if sold?
      errors.add(:item, "Cannot change sold item")
      false
    else
      true
    end
  end

  def reset_list_sent_on
    if list.sent_on
      list.sent_on = nil
      list.save
    end
  end

end
