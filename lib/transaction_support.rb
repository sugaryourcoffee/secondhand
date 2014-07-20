module TransactionSupport

#  def total
#    line_items.inject(0) { |sum, line_item| sum + line_item.price }
#  end

  def add_items_from_cart(cart)
    cart.line_items.each do |line_item|
      line_item.cart_id = nil
      line_items << line_item
    end 
  end

end
