def event_attributes(override = {})
  {
    deduction:          20,
    event_date:         Time.now,
    fee:                 3,
    location:           "Town",
    max_items_per_list: 30,
    max_lists:          30,
    provision:          15,
    title:              "An Event"
  }.merge(override)
end

def create_event
  Event.create(event_attributes)
end

def create_active_event
  Event.create(event_attributes(active: true))
end
