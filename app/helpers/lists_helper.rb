module ListsHelper

  def event_title_for(list)
    event = Event.find_by(id: list.event_id)
    if event
      event.title
    else
      list.event_id
    end
  end
  
  def user_for(list, link = true)
    user = User.find_by(id: list.user_id)
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

  # Return class value dependent on state. State can be that list is accepted
  # or list has been sent which ultimately means the seller has finished item
  # collection. If none of the states is achieved then nil is returned.
  def list_state(list)
    if list.accepted?
      "success"
    elsif list.sent_on
      "info"
    end
  end

  def list_info(list)
    if list.accepted?
      I18n.t('lists.status_list_accepted') 
    else
      I18n.t('lists.status_list_general', count: list.items.count,
             capacity: pluralize(list.free_item_capacity, I18n.t('lists.item')))
    end
  end

  def item_process_text(list)
    if list.accepted? || list.free_item_capacity == 0
      I18n.t('users.show.Item_viewing')
    else
      I18n.t('users.show.Item_collection')
    end
  end

  def new_item_link(list, user)
    if list.accepted?
      content_tag(:div, I18n.t('items.index.list_accepted'), class: "alert")
    elsif list.max_items_per_list?
      content_tag(:div, I18n.t('items.index.max_items_per_list'), 
                  class: "alert")
    else
      link_to t('.Create_New_Item'), 
                new_user_list_item_path(user, list), 
                class: "btn btn-primary"
    end
  end
end
