module ItemsHelper

  def list_item_number_for(item)
    sprintf("%03d/%02d", item.list.list_number, item.item_number) 
  end

end
