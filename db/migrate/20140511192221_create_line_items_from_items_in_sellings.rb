class CreateLineItemsFromItemsInSellings < ActiveRecord::Migration

  class Selling < ActiveRecord::Base
    has_many :items
    has_many :line_items
  end

  def up
    Selling.all.each do |selling|
      selling.items.each do |item|
        line_item = selling.line_items.build(item_id: item.id)
        line_item.save!
      end
      selling.items.delete_all
    end
  end

  def down
    Selling.all.each do |selling|
      selling.line_items.each do |line_item|
        selling.items << line_item.item
      end
      selling.line_items.delete_all
      selling.save!
    end
  end

end
