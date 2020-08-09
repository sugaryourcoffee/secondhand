require 'spec_helper'

describe Event do

  it "should respond to attributes" do
    event = Event.new

    expect(event).to respond_to(:title)
    expect(event).to respond_to(:event_date)
    expect(event).to respond_to(:location)
    expect(event).to respond_to(:fee)
    expect(event).to respond_to(:deduction)
    expect(event).to respond_to(:provision)
    expect(event).to respond_to(:max_lists)
    expect(event).to respond_to(:max_items_per_list)
    expect(event).to respond_to(:active)
    expect(event).to respond_to(:list_closing_date)
    expect(event).to respond_to(:delivery_location)
    expect(event).to respond_to(:delivery_date)
    expect(event).to respond_to(:delivery_start_time)
    expect(event).to respond_to(:delivery_end_time)
    expect(event).to respond_to(:collection_location)
    expect(event).to respond_to(:collection_date)
    expect(event).to respond_to(:collection_start_time)
    expect(event).to respond_to(:collection_end_time)
    expect(event).to respond_to(:information)
    expect(event).to respond_to(:alert_terms)
    expect(event).to respond_to(:alert_value)
  end

  it "requires a title" do
    event = Event.new(title: " ")

    expect(event).not_to be_valid
    expect(event.errors[:title].any?).to be_truthy # be_true
  end

  it "requires an event_date" do
    event = Event.new(event_date: nil)

    expect(event).not_to be_valid
    expect(event.errors[:event_date].any?).to be_truthy # be_true
  end

  it "requires a location" do
    event = Event.new(location: " ")

    expect(event).not_to be_valid
    expect(event.errors[:location].any?).to be_truthy # be_true
  end

  it "requires a fee" do
    event = Event.new(fee: " ")

    expect(event).not_to be_valid
    expect(event.errors[:fee].any?).to be_truthy # be_true
  end

  it "requires a deduction" do
    event = Event.new(deduction: " ")

    expect(event).not_to be_valid
    expect(event.errors[:deduction].any?).to be_truthy # be_true
  end

  it "requires a provision" do
    event = Event.new(provision: " ")

    expect(event).not_to be_valid
    expect(event.errors[:provision].any?).to be_truthy # be_true
  end

  it "requires max_lists" do
    event = Event.new(max_lists: " ")

    expect(event).not_to be_valid
    expect(event.errors[:max_lists].any?).to be_truthy # be_true
  end

  it "requires max_items_per_list" do
    event = Event.new(max_items_per_list: " ")

    expect(event).not_to be_valid
    expect(event.errors[:max_items_per_list].any?).to be_truthy # be_true
  end

  it "returns regex of alert terms" do
    event = Event.new(alert_terms: "house mouse yellow red")

    expect(event.alert_terms_regex).to eq /house|mouse|yellow|red/i
  end
end
