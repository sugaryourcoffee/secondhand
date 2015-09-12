require 'spec_helper'

describe "List with sold items" do

  let(:admin)         { FactoryGirl.create(:admin) }
  let(:seller)        { FactoryGirl.create(:user) }
  let(:event)         { FactoryGirl.create(:active) }
  let(:accepted_list) { FactoryGirl.create(:assigned, user: seller, 
                                           event: event) }

  before do
    accepted_list.items.create!(item_attributes)
    sign_in admin
  end

  describe "selling status page" do
    before do
      visit sold_items_list_path(locale: :en, id: accepted_list)
    end

    it "should have a header" do
      page.should have_selector 'h1', 
                       text: "List #{accepted_list.list_number} Selling Status"
    end

    it "should have a list header" do
      page.should have_text "Item"
      page.should have_text "Description"
      page.should have_text "Size"
      page.should have_text "Price"
      page.should have_text "Sold"
    end

    it "should have a list overview" do
      page.should have_text "List number"
      page.should have_text "Item count"
      page.should have_text "List value"
      page.should have_text "Revenue"
      page.should have_text "Fee"
      page.should have_text "Provision"
      page.should have_text "Payback"
    end

    it "should return from list selling status page to list index page" do
      click_link "Back"
      page.current_path.should eq lists_path(locale: :en)
    end

  end

  describe "list index page" do
    before { visit lists_path(locale: :en) }

    it "should have link to list selling status page" do
      page.current_path.should eq lists_path(locale: :en)
      page.should have_link "Show", 
                            sold_items_list_path(locale: :en, id: accepted_list)
    end

    it "should forward to list selling status page" do
      click_link "Show"
      page.current_path.should eq sold_items_list_path(locale: :en, 
                                                       id: accepted_list)
    end

  end
end

