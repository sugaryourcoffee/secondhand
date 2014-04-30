def create_selling_and_items(count = 1, event)
  selling = Selling.create!(event_id: event.id)
  count.times do |i|
    selling.items.create(item_attributes(item_number: i))
  end
  selling
end
