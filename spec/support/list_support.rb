# frozen_string_literal: true

def list_attributes(event, user, override = {})
  {
    list_number: '1',
    registration_code: 'abcdefghij',
    container: 'red',
    event_id: event.id,
    user_id: user.id
  }.merge(override)
end

def create_list(accepted, event, seller)
  list = List.create(list_attributes(event, seller))
  accepted ? accept(list) : lis
end

def accept(list)
  list.accepted_on = Time.now
  list.save!
  list.reload
end

def revoke_acceptance(list)
  list.accepted_on = nil
  list.save!
  list.reload
end
