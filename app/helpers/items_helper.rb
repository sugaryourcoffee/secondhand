module ItemsHelper

  def list_item_number_for(item)
    sprintf("%03d/%02d", item.list.list_number, item.item_number) 
  end

  def mark_alert_terms(description)
    regex       = Event.find_by(active: true).alert_terms_regex
    alert_terms = description.scan(regex) unless regex.nil?

    highlight(description, alert_terms)
  end

  def mark_alert_value(price)
    alert_value       = Event.find_by(active: true).alert_value
    formatted_price   = number_to_currency(price)
    highlighted_price = formatted_price if price >= alert_value

    highlight(formatted_price, highlighted_price)
  end

  def editable?(item)
    !(item.sold? || item.list.accepted?)
  end

  def row_status(item)
    "success" if item.sold?
  end
end
