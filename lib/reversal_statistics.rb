class ReversalStatistics

  def initialize(event)
    @event = event || Event.find_by_active(true)
  end

  def redemption_count
    @event.nil? ? 0 : Reversal.where("event_id = ?", @event.id).count
  end

  def redeemed_line_items
    LineItem.where("selling_id in (?) and reversal_id is not ?", selling_ids, 
                   nil)
  end

  def redeemed_items
    Item.where("id in (?)", item_ids)
  end

  def redeemed_line_items_count
    @event.nil? ? 0 : redeemed_line_items.count
  end

  def min_redemption_items
    @event.nil? ? 0 : redeemed_line_items.group(:reversal_id).count.values.min 
  end

  def max_redemption_items
    @event.nil? ? 0 : redeemed_line_items.group(:reversal_id).count.values.max
  end

  def redemption
    @event.nil? ? 0 : redeemed_items.sum(:price)
  end

  def min_redemption
    @event.nil? ? 0 : redemptions.min + 0
  end

  def max_redemption
    @event.nil? ? 0 : redemptions.max + 0
  end

  def average_redemption
    if @event.nil? 
      0 
    else
      redemption_count == 0 ? 0 : (redemption / redemption_count) + 0
    end
  end

  private

    def selling_ids
      Selling.where("event_id = ?", @event.id).pluck(:id)
    end

    def item_ids
<<<<<<< HEAD
      redeemed_line_items.pluck(:item_id) 
=======
      redeemed_line_items.pluck(:item_id) 
>>>>>>> rails4-0
    end

    def redemptions
      sums = []
      Redemption.where("event_id = ?", @event.id).each do |redemption|
        sums << redemption.total
      end
      sums
    end
end

