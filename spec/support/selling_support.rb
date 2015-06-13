def create_selling_and_items(event, list, item_count = 1, prices = [])
  prices = [22.5] * item_count if prices.empty?

  add_items_to_list(list, item_count, prices)

  accept(list) unless list.accepted?

  selling = Selling.new(event_id: event.id)

  items = list.reload.items

  0.upto(item_count-1) do |i|
    line_item = selling.line_items.build
    line_item.item = items[i]
  end

  selling.save!

  selling
end

def add_items_to_list(list, item_count = 1, prices = [])
  prices = [22.5] * item_count if prices.empty?
  accepted = list.accepted?
  revoke_acceptance(list) if accepted
  0.upto(item_count-1) do |i|
    list.items.create!(item_attributes(item_number: i+1, 
                                       price: prices[i] || 22.5))
  end
  accept(list) if accepted
end

def create_selling(event)
  seller = create_user
  list = List.create(list_attributes(event, seller))
  create_selling_and_items(event, list)
end
