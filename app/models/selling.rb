class Selling < ActiveRecord::Base

  include SellingsExporter
  include TransactionSupport

  belongs_to :event
  has_many :line_items
  has_many :reversals, through: :line_items
  
  attr_accessible :event_id

  before_destroy :ensure_line_items_empty

  scope :latest_on_top, lambda { order("created_at desc") }

  def total
    line_items.inject(0) { |sum, line_item| sum + (line_item.reversal ? 0 : line_item.price) } 
  end
=begin
  def revenue
    line_items.inject(0) { |sum, line_item| sum + line_item.price }
  end

  def add_items_from_cart(cart)
    cart.line_items.each do |line_item|
      line_item.cart_id = nil
      line_items << line_item
    end 
  end
=end
  private

    def ensure_line_items_empty
      errors.add(:selling, 
              "Cannot delete selling with line items") unless line_items.empty?
      line_items.empty?
    end

end
