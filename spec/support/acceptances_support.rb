def barcode_encoding_for(list, item)
  item_number = sprintf("%d%03d%02d", 
                        list.event_id, list.list_number, item.item_number) 
  Interleave2of5.new(item_number).encode.encodable + "\n"
end
