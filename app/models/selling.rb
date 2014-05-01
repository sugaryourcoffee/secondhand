class Selling < ActiveRecord::Base

  has_many   :items, dependent: :nullify
  belongs_to :event

  attr_accessible :event_id

  def revenue
    sum = 0
    items.each { |item| sum += item.price }
    sum
  end

end
