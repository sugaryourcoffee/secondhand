# == Schema Information
#
# Table name: events
#
#  id                 :integer          not null, primary key
#  title              :string(255)
#  event_date         :datetime
#  location           :string(255)
#  fee                :decimal(2, 2)
#  deduction          :decimal(2, 2)
#  provision          :decimal(2, 2)
#  max_lists          :integer
#  max_items_per_list :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  active             :boolean          default(FALSE)
#

class Event < ActiveRecord::Base
  has_many :lists
  has_many :users, through: :lists

  attr_accessible :deduction, :event_date, :fee, :location, :max_items_per_list, :max_lists, :provision, :title, :active

  validates :deduction, :event_date, :fee, :location, :max_items_per_list,
    :max_lists, :provision, :title, presence: true

  validates :deduction, :fee, :max_items_per_list, :max_lists, :provision, 
    numericality: {greater_than_or_equal_to: 1}

  validates :deduction, :fee, divisable: {divisor: 0.5}
end
