def add_items_to_cart(cart, list, item_count = 1)
  0.upto([item_count, list.items.count - 1].min) do |item|
    cart.add(list.items[item]).save
  end
end

def add_line_items_to_cart(cart, selling, line_item_count = 1)
  0.upto([line_item_count, selling.line_items.count - 1].min) do |line_item|
    cart.line_items << selling.line_items[line_item]
  end
  cart.save
end
