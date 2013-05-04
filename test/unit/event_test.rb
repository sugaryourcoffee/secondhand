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

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  test "event attributes must not be empty" do
    event = Event.new
    assert event.invalid?
    assert event.errors[:title].any?
    assert event.errors[:event_date].any?
    assert event.errors[:location].any?
    assert event.errors[:fee].any?
    assert event.errors[:deduction].any?
    assert event.errors[:provision].any?
    assert event.errors[:max_lists].any?
    assert event.errors[:max_items_per_list].any?
  end

  test "event numbers must be positive" do
    event = Event.new(
      title: 'Kleiderboerse Burgthann',
      location: 'Mittelschule Burgthann',
      event_date: Time.now,
      fee: 3,
      deduction: 20,
      provision: 15,
      max_lists: 200,
      max_items_per_list: 40
    )

    event.fee = -3
    assert event.invalid?
    assert_equal ["must be greater than or equal to 1"],
      event.errors[:fee]
    event.deduction = -20
    assert event.invalid?
    assert_equal ["must be greater than or equal to 1"],
      event.errors[:deduction]
    event.provision = -15
    assert event.invalid?
    assert_equal ["must be greater than or equal to 1"],
      event.errors[:provision]
    event.max_lists = -200
    assert event.invalid?
    assert_equal ["must be greater than or equal to 1"],
      event.errors[:max_lists]
    event.max_items_per_list = -40
    assert event.invalid?
    assert_equal ["must be greater than or equal to 1"],
      event.errors[:max_items_per_list]
    event.max_items_per_list = 0
    assert event.invalid?
    assert_equal ["must be greater than or equal to 1"],
      event.errors[:max_items_per_list]
    event.fee = 3
    event.deduction = 20
    event.provision = 15
    event.max_lists = 200
    event.max_items_per_list = 1
    assert event.valid?
  end

  test "fee and deduction must be divisible by 50 cent" do
    event = Event.new(
      title: 'Kleiderboerse Burgthann',
      location: 'Mittelschule Burgthann',
      event_date: Time.now,
      fee: 3,
      deduction: 20,
      provision: 15,
      max_lists: 200,
      max_items_per_list: 40
    )
    assert event.valid?
    event.fee = 3.4
    assert event.invalid?
    assert_equal ["has to be divisable by 0.5"],
      event.errors[:fee]
    event.deduction = 20.1
    assert event.invalid?
    assert_equal ["has to be divisable by 0.5"],
      event.errors[:deduction]
  end
end
