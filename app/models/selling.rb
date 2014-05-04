class Selling < ActiveRecord::Base

  has_many   :items, dependent: :nullify
  belongs_to :event

  attr_accessible :event_id

  def revenue
    sum = 0
    items.each { |item| sum += item.price }
    sum
  end

  def add_items_from_cart(cart)
    cart.items.each do |item|
      item.cart_id = nil
      items << item
    end 
  end

end
