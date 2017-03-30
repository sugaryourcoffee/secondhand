class Cart < ActiveRecord::Base
  has_many :line_items, -> { order(updated_at: :desc) },
           before_add: :ensure_line_item_unique!

  CART_TYPES = ['SALES', 'REDEMPTION']

  validates_inclusion_of :cart_type, in: CART_TYPES

  before_destroy :remove_line_items

  scope :not_empty, lambda { joins(:line_items).uniq }

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

  # Retrieves all carts that have line items
  def self.non_empty_carts
    Cart.joins(:line_items).where("cart_id not ?", nil)
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
