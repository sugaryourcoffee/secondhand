require 'spec_helper'

describe SellingStatistics do

  let(:event)            { FactoryGirl.create(:active) }
  let(:stats)            { SellingStatistics.new(event) }
  let(:seller)           { FactoryGirl.create(:user) }
  let!(:accepted_list)   { FactoryGirl.create(:accepted, 
                                              user: seller, 
                                              event: event) }
  let!(:selling)         { create_selling_and_items(event, accepted_list, 2) }
  let!(:accepted_list_2) { FactoryGirl.create(:accepted, 
                                              user: seller, 
                                              event: event) }
  let!(:selling_2)       { create_selling_and_items(event, accepted_list_2, 5) }

  it "should return event's count of sellings" do
    stats.selling_count.should eq 2
  end

  it "should return event's count of sold items" do
    stats.sold_items_count.should eq 7
  end

  it "should return list and item count of list with least items" do
    stats.min_selling_items.should eq 2
  end

  it "should return list and item count of list with most items" do
    stats.max_selling_items.should eq 5
  end

  it "should return event's revenue" do
    stats.revenue.should eq 157.5
  end

  it "should return event's profit" do
    stats.profit.should eq 23.5
  end

  it "should return sellings min revenue" do
    stats.min_revenue.should eq 45.0
  end

  it "should return sellings max revenue" do
    stats.max_revenue.should eq 112.5
  end

  it "should return sellings average revenue" do
    stats.average_revenue.should eq 78.75
  end

end
