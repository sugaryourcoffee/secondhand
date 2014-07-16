class SellingStatistics

  def initialize(event)
    @event = event || Event.find_by_active(true)
    @revenues, @fees, @provisions = revenues
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

  # Calculation of profit
  # profit = fee + provision
  # fee    = @event.fee -> fee is only deducted if revenue < @event.deduction
  # provision = revenue / 100 * @event.provision if revenue >= @event.deduction
  # payback   = revenue + fee - provision rounded to 1 if >= .75 to .5 if >= 0.25 otherwise 0
  def profit
    fee = @fees.count * @event.fee
    provision = @provisions.inject(:+) / 100 * @event.provision
    round_dot_five(0.0 + fee + provision)
  end

  def min_revenue
    @event.nil? ? 0 : @revenues.min + 0
  end

  def max_revenue
    @event.nil? ? 0 : @revenues.max + 0
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

    # Returns all revenues, revenues that are subject to fee only and revenues
    # that are subject to provision
    #     revenues -> [revenues, fee_revenues, provision_revenues]
    def revenues
      sums       = []
      fees       = []
      provisions = []
      Selling.where("event_id = ?", @event.id).each do |selling|
        sums << selling.total
        if sums.last < @event.deduction
          fees << sums.last
        else
          provisions << sums.last
        end
      end
      [sums, fees, provisions]
    end

    # Rounds values in 0.5 steps
    # 0.24 -> 0.0
    # 0.25 -> 0.5
    # 0.74 -> 0.5
    # 0.75 -> 1.0
    def round_dot_five(value)
      remainder = value.remainder(1)
      floor     = value.floor
      remainder >= 0.75 ? value.round : remainder >= 0.25 ? floor + 0.5 : floor
    end

end

