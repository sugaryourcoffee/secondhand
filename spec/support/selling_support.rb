def create_selling_and_items(event, list, item_count = 1)
  add_items_to_list(list, item_count)

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

def add_items_to_list(list, item_count = 1)
  accepted = list.accepted?
  revoke_acceptance(list) if accepted
  1.upto(item_count) do |i|
    list.items.create!(item_attributes(item_number: i))
  end
  accept(list) if accepted
end
