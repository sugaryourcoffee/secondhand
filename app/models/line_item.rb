class LineItem < ActiveRecord::Base
  belongs_to :item
  belongs_to :selling
  belongs_to :reversal
  belongs_to :cart

  attr_accessible :cart_id, :item_id, :reversal_id, :selling_id

  delegate :price, to: :item

  before_save :ensure_item_not_nil,
              :ensure_item_from_accepted_list_of_active_event,
              :ensure_item_not_sold,
              :ensure_item_not_in_cart 

  private

    def ensure_item_not_nil
      errors.add(:items, "Empty item cannot be added") if item.nil?
      !item.nil?
    end

    def ensure_item_from_accepted_list_of_active_event
      active_event = Event.find_by_active(true)
      item_valid = !active_event.nil? && 
                   item.list.event_id = active_event.id &&
                   !item.list.accepted_on.nil?

      errors.add(:items, "Item must be from an accepted list of an active event") unless item_valid
      item_valid
    end

    def ensure_item_not_sold
      items = LineItem.where("item_id = ? and reversal_id is ?", item.id, nil)
      unless items.empty?
        raise "Item is sold #{items.size} times" if items.size > 1
        line_item = items.first
        errors.add(:items, 
                   "Item is already sold with selling #{line_item.selling_id}")
      end
      items.empty?
    end

    def ensure_item_not_in_cart
      return true if item.nil?

      line_items = LineItem.where("item_id = ? and cart_id is not ?", 
                                  item.id, nil)

      unless line_items.empty?
        raise "Item is in #{line_items.size} carts" if line_items.size > 1
        errors.add(:items, 
                   "Item is already in cart #{line_items.first.cart_id}")
      end

      line_items.empty?
    end
    
end
