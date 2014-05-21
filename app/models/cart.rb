class Cart < ActiveRecord::Base
  has_many :items, dependent: :nullify
  # begin not tested yet
  has_many :line_items, dependent: :destroy
  # end not tested yet

  before_save :ensure_items_are_from_accepted_lists_of_active_event, 
              :ensure_items_are_unique, :ensure_items_not_sold

  def total
    items.to_a.sum { |item| item.price }
  end

  def add(item)
    if item.nil?
      errors.add(:items, 'Item does not exist!')
      false
    else #if can_add_item?(item)
      #items << item
      line_item = line_items.build
      line_item.item = item
      line_item.save
    end
  end

  def remove(item)
    if item.cart_id == id
      items.delete item
      true
    else
      errors.add(:items, 'Item to be removed is not in the cart')
      false
    end
  end

  private

    def item_from_active_event_and_accepted_list?(item)
      active_event = Event.find_by_active(true)
      !active_event.nil? && (item.list.event.id == active_event.id) && !item.list.accepted_on.nil?
    end

    def ensure_items_are_from_accepted_lists_of_active_event
      active_event = Event.find_by_active(true)
      items_valid  = true

      items.each do |item|
        items_valid = items_valid && !active_event.nil? && !item.list.accepted_on.nil?  && 
                      (item.list.event.id == active_event.id)

        break unless items_valid
      end

      errors.add(:items, 
                 'Only items from accepted lists of an active event can be added!') unless items_valid

      items_valid
    end

    def ensure_items_are_unique
      return true if items.empty?
      
      ids = items.collect { |item| item.id }
      
      items_valid = ids.size == ids.uniq.size

      errors.add(:items, 'Item is already in the cart!') unless items_valid

      items_valid
    end

    def can_add_item?(item)
      if item.cart_id == id
        errors.add(:items, 'Item is already in the cart!')
      elsif !item.cart_id.nil?
        errors.add(:items, "Item is already in cart #{item.cart_id}")
      end
      errors.add(:items, "Item is already sold with selling #{item.selling_id}") unless item.selling_id.nil?
      errors.add(:items, 'Only items from accepted lists of an active event can be added!') unless item_from_active_event_and_accepted_list?(item)

      item.cart_id.nil? && item.selling_id.nil? && item_from_active_event_and_accepted_list?(item)
    end

    def ensure_items_not_sold
      items_valid = true

      items.each do |item|
        items_valid = items_valid && item.selling_id.nil?
        unless items_valid
          errors.add(:items, "Item is already sold with selling #{item.selling_id}")
          break
        end
      end

      items_valid
    end
end
