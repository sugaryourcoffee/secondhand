require 'spec_helper'

describe Reversal do
  
  let(:event)                  { FactoryGirl.create(:active) }
  let(:seller)                 { FactoryGirl.create(:user) }
  let(:list_with_sold_items)   { FactoryGirl.create(:accepted, event: event, user: seller) }
  let(:selling)                { create_selling_and_items(event, list) }
  let(:list_with_unsold_items) { FactoryGirl.create(:accepted, event: event, user: seller) }

  it "should respond to attributes" do
    reversal = Reversal.new

    reversal.should respond_to :line_items
  end

  it "should add sold items" do
    reversal = Reversal.new
    reversal.line_items.should be_empty

    line_item = reversal.line_items.build
    line_item.item = list_with_sold_items.items.first
    line_item.save

    line_item.errors.any?.should be_false

    reversal.line_items.should_not be_empty

    list_with_sold_items.items.first.line_item.should_not be_nil
  end

  it "should not add unsold items" do
    reversal = Reversal.new
    reversal.line_items.should be_empty

    line_item = reversal.line_items.build
    line_item.item = list_with_unsold_items.items.first
    line_item.save

    line_item.errors.any?.should be_true

    reversal.line_items.should be_empty

    list_with_unsold_items.items.first.line_item.should be_nil
  end

  it "should remove line items" do
    reversal = Reversal.new
    reversal.line_items.should be_empty

    line_item = reversal.line_items.build
    line_item.item = list_with_sold_items.items.first
    line_item.save

    line_items.errors.any?.should be_false

    reversal.line_items.should_not be_empty

    line_item.destroy

    reversal.line_items.should be_empty

    list_with_sold_items.items.first.line_item.should be_nil
  end

  it "should mark items as unsold and remove them from sellings" do
    reversal = Reversal.new
    reversal.line_items.should be_empty

    line_item = reversal.line_items.build
    line_item.item = list_with_sold_items.items.first
    line_item.save

    line_items.errors.any?.should be_false

    reversal.line_items.should_not be_empty


  end

end
