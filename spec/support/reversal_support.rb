def create_reversal(event, selling = nil, offset = 0, line_item_count = 1)
  reversal = Reversal.new(event_id: event.id)
  selling  = create_selling(event, line_item_count) unless selling

  raise "invalid line item count" if offset + line_item_count > selling.
                                                            line_items.size 

  offset.upto(offset + line_item_count - 1) do |i|
    reversal.line_items << selling.line_items[i]
  end

  reversal.save

  reversal 
end
