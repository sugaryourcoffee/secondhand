def add_item_to_cart(cart, item)
  line_item = cart.line_items.build
  line_item.item = item
  line_item
end
