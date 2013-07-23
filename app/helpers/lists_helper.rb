module ListsHelper

  def event_title_for(list)
    event = Event.find_by_id(list.event_id)
    if event
      event.title
    else
      list.event_id
    end
  end
  
  def user_for(list)
    user = User.find_by_id(list.user_id)
    if user
      link_to "#{user.last_name}, #{user.first_name}", user
    else
      list.user_id
    end
  end

end
