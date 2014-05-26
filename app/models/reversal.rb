class Reversal < ActiveRecord::Base
  has_many :line_items
  has_many :sellings, through: :line_items

  before_destroy :ensure_line_items_empty

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
