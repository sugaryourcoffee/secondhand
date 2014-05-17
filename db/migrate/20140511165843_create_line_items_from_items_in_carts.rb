class CreateLineItemsFromItemsInCarts < ActiveRecord::Migration

  class Cart < ActiveRecord::Base
    has_many :items
    has_many :line_items
  end

  def up
    Cart.all.each do |cart|
      cart.items.each do |item|
        line_item = cart.line_items.build(item_id: item.id)
        line_item.save!
      end
      cart.items.delete_all
    end
  end

  def down
    Cart.all.each do |cart|
      cart.line_items.each do |line_item|
        cart.items << line_item.item
      end
      cart.line_items.delete_all
      cart.save!
    end
  end

end
