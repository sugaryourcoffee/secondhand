require 'spec_helper'

describe "List with sold items" do

  let(:operator)      { FactoryGirl.create(:operator) }
  let(:seller)        { FactoryGirl.create(:user) }
  let(:event)         { FactoryGirl.create(:active) }
  let(:accepted_list) { FactoryGirl.create(:assigned, user: seller, 
                                           event: event) }

  before do
    accepted_list.items.create!(item_attributes)
    sign_in operator
    visit sold_items_list_path(locale: :en, id: accepted_list)
  end

  it "should have a list header" do
    page.should have_text "Item"
    page.should have_text "Description"
    page.should have_text "Size"
    page.should have_text "Price"
    page.should have_text "Sold"
  end

  it "should have a list overview" do
    page.should have_text "Items"
    page.should have_text "List value"
    page.should have_text "Revenue"
    page.should have_text "Fee"
    page.should have_text "Provision"
    page.should have_text "Payback"
  end

end

