require 'spec_helper'

describe Reversal do
  
  let(:event)                  { FactoryGirl.create(:active) }
  let(:seller)                 { FactoryGirl.create(:user) }
  let(:list_with_sold_items)   { FactoryGirl.create(:accepted, 
                                                    event: event, 
                                                    user: seller) }
  let(:list_with_unsold_items) { FactoryGirl.create(:accepted, 
                                                    event: event,
                                                    user: seller) }

  let!(:selling) { create_selling_and_items(event, list_with_sold_items) }

  it "should respond to attributes" do
    reversal = Reversal.new

    reversal.should respond_to :line_items
  end

  it "should add sold items" do
    reversal = Reversal.create!
    reversal.line_items.should be_empty

    list_with_sold_items.items.first.sold?.should be_true

    line_item = reversal.line_items.build
    line_item.item = list_with_sold_items.items.first
    line_item.save

    line_item.errors.any?.should be_false

    reversal.line_items.should_not be_empty

    list_with_sold_items.items.first.reversals.should_not be_empty
    list_with_sold_items.items.first.sold?.should be_false
  end

  it "should not add unsold items" do
    add_items_to_list(event, list_with_unsold_items)

    list_with_unsold_items.items.first.sold?.should be_false

    reversal = Reversal.create!
    reversal.line_items.should be_empty

    line_item = reversal.line_items.build
    line_item.item = list_with_unsold_items.items.first
    line_item.save

    line_item.errors.any?.should be_true

    reversal.line_items.should be_empty

    list_with_unsold_items.items.first.reversals.should be_empty
    list_with_unsold_items.items.first.sold?.should be_false
  end

  it "should not remove line items" do
    reversal = Reversal.create!
    reversal.line_items.should be_empty

    line_item = reversal.line_items.build
    line_item.item = list_with_sold_items.items.first
    line_item.save

    line_item.errors.any?.should be_false

    reversal.line_items.should_not be_empty
    list_with_sold_items.items.first.reversals.should_not be_empty

    line_item.destroy
    line_item.errors.any?.should be_true

    reversal.line_items.should_not be_empty
    list_with_sold_items.items.first.reversals.should_not be_empty
    list_with_sold_items.items.first.sold?.should_not be_true
  end

  it "should not destroy a reversal with line items" do
    reversal = Reversal.create!
    
    line_item = reversal.line_items.build
    line_item.item = list_with_sold_items.items.first
    line_item.save

    line_item.errors.any?.should be_false

    reversal.destroy
    reversal.errors.any?.should be_true

    reversal.line_items.should_not be_empty
    list_with_sold_items.items.first.reversals.should_not be_empty
    list_with_sold_items.items.first.sold.should_not be_true
  end

  it "should mark items as unsold and mark them as reversed in selling" do
    reversal = Reversal.new
    reversal.line_items.should be_empty

    line_item = reversal.line_items.build
    line_item.item = list_with_sold_items.items.first
    line_item.save

    line_item.errors.any?.should be_false

    reversal.line_items.should_not be_empty
    list_with_sold_items.items.first.sold?.should_not be_true
    selling.line_items.first.reversed?.should be_true
  end

end
