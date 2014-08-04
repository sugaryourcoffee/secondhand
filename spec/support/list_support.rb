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
