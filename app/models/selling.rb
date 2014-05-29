class Selling < ActiveRecord::Base

  include SellingsExporter

  has_many   :items, dependent: :nullify
  belongs_to :event
  # begin not tested yet
  has_many :line_items
  has_many :reversals, through: :line_items
  # end not tested yet
  
  attr_accessible :event_id

  def revenue
    line_items.inject(0) { |sum, line_item| sum + line_item.price }
  end

  def remove(item)
    if item.selling_id == id
      items.delete item
      true
    else
      errors.add(:items, 'Item to be removed is not in the selling')
      false
    end
  end

  def add_items_from_cart(cart)
    cart.line_items.each do |line_item|
      line_item.cart_id = nil
      line_items << line_item
    end 
  end

end
