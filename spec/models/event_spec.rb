require 'spec_helper'

describe Event do

  it "should respond to attributes" do
    event = Event.new

    event.should respond_to(:title)
    event.should respond_to(:event_date)
    event.should respond_to(:location)
    event.should respond_to(:fee)
    event.should respond_to(:deduction)
    event.should respond_to(:provision)
    event.should respond_to(:max_lists)
    event.should respond_to(:max_items_per_list)
    event.should respond_to(:active)
    event.should respond_to(:list_closing_date)
    event.should respond_to(:delivery_location)
    event.should respond_to(:delivery_date)
    event.should respond_to(:delivery_start_time)
    event.should respond_to(:delivery_end_time)
    event.should respond_to(:collection_location)
    event.should respond_to(:collection_date)
    event.should respond_to(:collection_start_time)
    event.should respond_to(:collection_end_time)
    event.should respond_to(:information)
  end

  it "requires a title" do
    event = Event.new(title: " ")

    event.should_not be_valid
    event.errors[:title].any?.should be_truthy # be_true
  end

  it "requires an event_date" do
    event = Event.new(event_date: nil)

    event.should_not be_valid
    event.errors[:event_date].any?.should be_truthy # be_true
  end

  it "requires a location" do
    event = Event.new(location: " ")

    event.should_not be_valid
    event.errors[:location].any?.should be_truthy # be_true
  end

  it "requires a fee" do
    event = Event.new(fee: " ")

    event.should_not be_valid
    event.errors[:fee].any?.should be_truthy # be_true
  end

  it "requires a deduction" do
    event = Event.new(deduction: " ")

    event.should_not be_valid
    event.errors[:deduction].any?.should be_truthy # be_true
  end

  it "requires a provision" do
    event = Event.new(provision: " ")

    event.should_not be_valid
    event.errors[:provision].any?.should be_truthy # be_true
  end

  it "requires max_lists" do
    event = Event.new(max_lists: " ")

    event.should_not be_valid
    event.errors[:max_lists].any?.should be_truthy # be_true
  end

  it "requires max_items_per_list" do
    event = Event.new(max_items_per_list: " ")

    event.should_not be_valid
    event.errors[:max_items_per_list].any?.should be_truthy # be_true
  end
end
