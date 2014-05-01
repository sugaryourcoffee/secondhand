class SellingStatistics

  def initialize(event)
    @event = event || Event.find_by_active(true)
  end

  def selling_count
    @event.nil? ? 0 : Selling.where("event_id = ?", @event.id).count
  end

  def sold_items_count
    @event.nil? ? 0 : Item.where(selling_id: selling_ids).count
  end

  def min_selling_items
    @event.nil? ? 0 : Item.group(:selling_id).where(selling_id: selling_ids).count.values.min 
  end

  def max_selling_items
    @event.nil? ? 0 : Item.group(:selling_id).where(selling_id: selling_ids).count.values.max
  end

  def revenue
    @event.nil? ? 0 : Item.where(selling_id: selling_ids).sum(:price)
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

    def revenues
      sums = []
      Selling.where("event_id = ?", @event.id).each do |selling|
        sums << selling.items.sum(:price)
      end
      sums
    end
end

