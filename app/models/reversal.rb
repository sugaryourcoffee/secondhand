class Reversal < ActiveRecord::Base
  include SellingsExporter
  include TransactionSupport

  belongs_to :event
  has_many :line_items
  has_many :sellings, through: :line_items

  attr_accessible :event_id

  before_destroy :ensure_line_items_empty

  scope :latest_on_top, lambda { order('created_at desc') }

  def total
    line_items.inject(0) { |sum, line_item| sum + line_item.price }
  end

  private

    def ensure_line_items_empty
      if line_items.empty?
        true
      else
        errors.add(:line_item, "Cannot delete reversal with line items") 
        false
      end
    end

end
