class ListStatistics

  def initialize(event)
    @event = event || Event.find_by_active(true)
  end

  def accepted_lists_count
    List.accepted(@event.id).count
  end

  def not_yet_accepted_lists_count
    List.not_yet_accepted(@event.id).count
  end

  def total_list_count
    List.total_count(@event.id).count
  end

end
