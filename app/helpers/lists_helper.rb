module ListsHelper

  def event_title_for(list)
    event = Event.find_by(id: list.event_id) #find_by_id(list.event_id)
    if event
      event.title
    else
      list.event_id
    end
  end
  
  def user_for(list, link = true)
    user = User.find_by(id: list.user_id) # find_by_id(list.user_id)
    if user
      if link
        link_to "#{user.last_name}, #{user.first_name}", user
      else
        "#{user.last_name}, #{user.first_name}"
      end
    else
      list.user_id
    end
  end

end
