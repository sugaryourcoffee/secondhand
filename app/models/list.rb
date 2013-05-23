# == Schema Information
#
# Table name: lists
#
#  id                :integer          not null, primary key
#  list_number       :integer
#  registration_code :string(255)
#  container         :string(255)
#  event_id          :integer
#  user_id           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class List < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  has_many :items

  attr_accessible :container, :event_id, :list_number, :registration_code, :user_id
end
