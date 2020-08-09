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

    expect(reversal).to respond_to :line_items
  end

  it "should add sold items" do
    reversal = Reversal.new

    expect(list_with_sold_items.items.first.sold?).to be_truthy # be_true

    reversal.line_items << selling.line_items.first 

    expect { reversal.save }.to change(Reversal, :count).by(1)

    expect(reversal.line_items).not_to be_empty

    expect(list_with_sold_items.reload.items.first.reversals).not_to be_empty
    expect(list_with_sold_items.items.first.sold?).to be_falsey # be_false
  end

  it "should not add unsold items" do
    add_items_to_list(list_with_unsold_items)

    expect(list_with_unsold_items.items.first.sold?).to be_falsey # be_false

    reversal = Reversal.new

    line_item = reversal.line_items.build
    line_item.item = list_with_unsold_items.items.first
    reversal.save

    expect(reversal.reload.line_items).to be_empty
  end

  it "should not remove line items" do
    reversal = Reversal.new

    line_item = selling.line_items.first
    reversal.line_items << line_item
    reversal.save

    expect(reversal.line_items).not_to be_empty

    line_item.destroy
    expect(line_item.errors.any?).to be_truthy # be_true

    expect(reversal.line_items).not_to be_empty
    expect(list_with_sold_items.items.first.sold?).not_to be_truthy # be_true
  end

  it "should not destroy a reversal with line items" do
    reversal = Reversal.new
    
    reversal.line_items << selling.line_items.first
    reversal.save

    expect { reversal.destroy }.to change(Reversal, :count).by(0)
    expect(reversal.errors.any?).to be_truthy # be_true

    expect(reversal.line_items).not_to be_empty
  end

  it "should mark items as unsold and mark them as reversed in selling" do
    reversal = Reversal.new

    expect(selling.line_items.first.item.sold?).to be_truthy # be_true

    reversal.line_items << selling.line_items.first
    reversal.save

    expect(reversal.line_items).not_to be_empty

    expect(list_with_sold_items.items.first.sold?).not_to be_truthy # be_true
  end

end
