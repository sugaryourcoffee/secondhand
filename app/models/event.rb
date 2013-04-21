class Event < ActiveRecord::Base
  attr_accessible :deduction, :event_date, :fee, :location, :max_items_per_list, :max_lists, :provision, :title
end
