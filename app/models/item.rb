class Item < ActiveRecord::Base
  belongs_to :list

  attr_accessible :description, :item_number, :price, :size

  validates :list_id, presence: true
end
