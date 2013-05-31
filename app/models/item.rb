class Item < ActiveRecord::Base
  belongs_to :list

  attr_accessible :description, :item_number, :price, :size

  validates :list_id, :description, :item_number, :price, presence: true
  validates :price, numericality: { greater_than_or_equal: 0.5 }
  validates :price, divisable: { divisor: 0.5 }
end
