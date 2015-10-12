class ListStatistics

  def initialize(event)
    @event = event || Event.find_by(active: true)
  end

  def registered_lists_count
    @event.nil? ? 0 : List.registered(@event.id).count
  end

  def not_registered_lists_count
    @event.nil? ? 0 : List.not_registered(@event.id).count
  end

  def accepted_lists_count
    @event.nil? ? 0 : List.accepted(@event.id).count
  end

  def not_accepted_lists_count
    @event.nil? ? 0 : List.not_accepted(@event.id).count
  end

  def total_lists_count
    @event.nil? ? 0 : List.total_count(@event.id).count
  end

end
