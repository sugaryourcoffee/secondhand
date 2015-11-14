module ItemsHelper

  def list_item_number_for(item)
    sprintf("%03d/%02d", item.list.list_number, item.item_number) 
  end

  def mark_alert_terms(description)
    regex = Event.find_by(active: true).alert_terms_regex
    alert_terms = description.scan(regex) unless regex.nil?
    highlight(description, alert_terms)
  end

end
