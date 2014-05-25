class SellingStatistics

  def initialize(event)
    @event = event || Event.find_by_active(true)
  end

  def selling_count
    @event.nil? ? 0 : Selling.where("event_id = ?", @event.id).count
  end

  def sold_line_items
    LineItem.where("selling_id in (?) and reversal_id is ?", selling_ids, nil)
  end

  def sold_items
    Item.where("id in (?)", item_ids)
  end

  def sold_items_count
    @event.nil? ? 0 : sold_line_items.count
  end

  def min_selling_items
    @event.nil? ? 0 : sold_line_items.group(:selling_id).count.values.min 
  end

  def max_selling_items
    @event.nil? ? 0 : sold_line_items.group(:selling_id).count.values.max
  end

  def revenue
    @event.nil? ? 0 : sold_items.sum(:price)
  end

  def profit
  end

  def min_revenue
    @event.nil? ? 0 : revenues.min + 0
  end

  def max_revenue
    @event.nil? ? 0 : revenues.max + 0
  end

  def average_revenue
    if @event.nil? 
      0 
    else
      selling_count == 0 ? 0 : (revenue / selling_count) + 0
    end
  end

  private

    def selling_ids
      Selling.where("event_id = ?", @event.id).pluck(:id)
    end

    def item_ids
      sold_line_items.select('item_id').pluck(:id)
    end

    def revenues
      sums = []
      Selling.where("event_id = ?", @event.id).each do |selling|
        sums << selling.revenue
      end
      sums
    end
end

