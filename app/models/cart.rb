class Cart < ActiveRecord::Base
  has_many :line_items, before_add: :ensure_line_item_unique!

  CART_TYPES = ['SALES', 'REDEMPTION']

  attr_accessible :cart_type

  validates_inclusion_of :cart_type, in: CART_TYPES

  before_destroy :remove_line_items

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

  private

    def ensure_line_item_unique!(line_item)
      raise ActiveRecord::RecordNotSaved if line_items.include?(line_item)
    end

    def remove_line_items
      if cart_type == 'SALES'
        line_items.destroy_all
      else
        line_items.delete_all
      end
    end

end
