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
    reversal = Reversal.new

    list_with_sold_items.items.first.sold?.should be_truthy # be_true

    reversal.line_items << selling.line_items.first 

    expect { reversal.save }.to change(Reversal, :count).by(1)

    reversal.line_items.should_not be_empty

    list_with_sold_items.reload.items.first.reversals.should_not be_empty
    list_with_sold_items.items.first.sold?.should be_falsey # be_false
  end

  it "should not add unsold items" do
    add_items_to_list(list_with_unsold_items)

    list_with_unsold_items.items.first.sold?.should be_falsey # be_false

    reversal = Reversal.new

    line_item = reversal.line_items.build
    line_item.item = list_with_unsold_items.items.first
    reversal.save

    reversal.reload.line_items.should be_empty
  end

  it "should not remove line items" do
    reversal = Reversal.new

    line_item = selling.line_items.first
    reversal.line_items << line_item
    reversal.save

    reversal.line_items.should_not be_empty

    line_item.destroy
    line_item.errors.any?.should be_truthy # be_true

    reversal.line_items.should_not be_empty
    list_with_sold_items.items.first.sold?.should_not be_truthy # be_true
  end

  it "should not destroy a reversal with line items" do
    reversal = Reversal.new
    
    reversal.line_items << selling.line_items.first
    reversal.save

    expect { reversal.destroy }.to change(Reversal, :count).by(0)
    reversal.errors.any?.should be_truthy # be_true

    reversal.line_items.should_not be_empty
  end

  it "should mark items as unsold and mark them as reversed in selling" do
    reversal = Reversal.new

    selling.line_items.first.item.sold?.should be_truthy # be_true

    reversal.line_items << selling.line_items.first
    reversal.save

    reversal.line_items.should_not be_empty

    list_with_sold_items.items.first.sold?.should_not be_truthy # be_true
  end

end
