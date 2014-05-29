def add_items_to_cart(cart, list, item_count = 1)
  0.upto([item_count, list.items.count - 1].min) do |item|
    cart.add(list.items[item]).save
  end
end
