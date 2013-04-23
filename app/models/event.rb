class Event < ActiveRecord::Base
  attr_accessible :deduction, :event_date, :fee, :location, :max_items_per_list, :max_lists, :provision, :title

  validates :deduction, :event_date, :fee, :location, :max_items_per_list,
    :max_lists, :provision, :title, presence: true

  validates :deduction, :fee, :max_items_per_list, :max_lists, :provision, 
    numericality: {greater_than_or_equal_to: 1}

  validates :deduction, :fee, divisable: {divisor: 0.5}
end
