require 'spec_helper'

describe Selling do
  
  let(:event)  { FactoryGirl.create(:active) }
  let(:seller) { FactoryGirl.create(:user) }
  let(:list)   { FactoryGirl.create(:accepted, user: seller, event: event) }

  it "should respond to attributes" do
    selling = Selling.new
    selling.should respond_to :line_items
    selling.should respond_to :to_pdf
    selling.should respond_to :total
  end

  it "should return the line item of sold item" do
    selling = create_selling_and_items(event, list)
    
    line_item = LineItem.sold(list.items.first)

    line_item.item.should eq list.items.first
  end

  it "should return the revenue" do
    selling = create_selling_and_items(event, list)
    
    revenue = 0
    list.items.each { |item| revenue += item.price }

    selling.total.should eq revenue

  end  

  it "should not delete selling" do
    selling = create_selling_and_items(event, list)

    expect { selling.destroy }.to change(Selling, :count).by(0)

    selling.errors.any?.should be_truthy # be_true
  end

end
