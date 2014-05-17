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
    sum = 0
    items.each { |item| sum += item.price }
    sum
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
    cart.items.each do |item|
      item.cart_id = nil
      items << item
    end 
  end

end
