class LineItem < ActiveRecord::Base
  belongs_to :item
  belongs_to :selling
  belongs_to :reversal
  belongs_to :cart

  attr_accessible :cart_id, :item_id, :reversal_id, :selling_id

  delegate :price, to: :item

  validates :item_id, presence: true

  before_save :ensure_item_from_accepted_list_of_active_event,
              :ensure_reversal_only_with_selling

  before_create :ensure_item_not_sold,
                :ensure_item_not_in_cart 

  before_destroy :ensure_not_referenced_by_selling_or_reversal

  private

    def ensure_item_from_accepted_list_of_active_event
      active_event = Event.find_by_active(true)
      item_valid = !active_event.nil? && 
                   item.list.event_id = active_event.id &&
                   !item.list.accepted_on.nil?

      errors.add(:items, "Item must be from an accepted list of an active event") unless item_valid
      item_valid
    end

    def ensure_reversal_only_with_selling
      if reversal
        selling.nil? ? false : true
      else
        true
      end  
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

    def ensure_not_referenced_by_selling_or_reversal
      errors.add(:items, "Sold item cannot be deleted")     unless selling.nil?
      errors.add(:items, "Reversed item cannot be deleted") unless reversal.nil?
      selling.nil? && reversal.nil?
    end
    
end
