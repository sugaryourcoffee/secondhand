class Cart < ActiveRecord::Base
  has_many :line_items, dependent: :destroy

  def total
    line_items.inject(0) { |sum, line_item| sum + line_item.price }
  end

  # Associates new line_item to cart and returns line_item. Returned line_item
  # has to be saved in calling object.
  def add(item)
    line_item = line_items.build
    line_item.item = item
    line_item
  end

end
