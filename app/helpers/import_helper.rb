module ImportHelper

  def capacity_information(capacity)
    if capacity > 0
      "You can add #{capacity} more items"
    elsif capacity == 0
      "You can add no more items"
    else
      "You have to deselect #{capacity.to_i.abs} items"
    end
  end

end
