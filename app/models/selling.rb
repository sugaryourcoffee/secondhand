class Selling < ActiveRecord::Base

  has_many   :items
  belongs_to :event

  attr_accessible :event_id

  def revenue
    items.sum(:+) { |item| item.price }
  end
end
