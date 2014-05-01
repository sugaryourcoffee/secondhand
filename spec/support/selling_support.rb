def create_selling_and_items(event, list, item_count = 1)
  1.upto(item_count) do |i|
    list.items.create!(item_attributes(item_number: i))
  end

  selling = Selling.new(event_id: event.id)

  items = list.items

  0.upto(item_count-1) do |i|
    selling.items << items[i]
  end

  selling.save!

  selling
end
