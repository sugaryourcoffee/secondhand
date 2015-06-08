def add_items_to_cart(cart, list, item_count = 1)
  0.upto([item_count, list.items.count - 1].min) do |item|
    line_item = cart.add(list.items[item])
    line_item.save
  end
end

def add_line_items_to_cart(cart, selling, line_item_count = 1)
  0.upto([line_item_count, selling.line_items.count - 1].min) do |line_item|
    cart.line_items << selling.line_items[line_item]
  end
  cart.save
end

def create_cart_with_line_items(event, line_item_count = 1)
  cart   = Cart.create
  seller = create_user
  list   = List.create(list_attributes(event, seller))
  add_items_to_list(list, 2)
  add_items_to_cart(cart, accept(list), line_item_count)
  cart
end
