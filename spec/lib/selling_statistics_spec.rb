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
    expect(stats.selling_count).to eq 2
  end

  it "should return event's count of sold items" do
    expect(stats.sold_items_count).to eq 7
  end

  it "should return list and item count of list with least items" do
    expect(stats.min_selling_items).to eq 2
  end

  it "should return list and item count of list with most items" do
    expect(stats.max_selling_items).to eq 5
  end

  it "should return event's revenue" do
    expect(stats.revenue).to eq 157.5
  end

  it "should return event's profit" do
    expect(stats.profit).to eq 23.5
  end

  it "should return sellings min revenue" do
    expect(stats.min_revenue).to eq 45.0
  end

  it "should return sellings max revenue" do
    expect(stats.max_revenue).to eq 112.5
  end

  it "should return sellings average revenue" do
    expect(stats.average_revenue).to eq 78.75
  end

end
