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
      expect(page).to have_selector 'h1', 
                       text: "List #{accepted_list.list_number} Selling Status"
    end

    it "should have a list header" do
      expect(page).to have_text "Item"
      expect(page).to have_text "Description"
      expect(page).to have_text "Size"
      expect(page).to have_text "Price"
      expect(page).to have_text "Sold"
    end

    it "should have a list overview" do
      expect(page).to have_text "List number"
      expect(page).to have_text "Item count"
      expect(page).to have_text "List value"
      expect(page).to have_text "Revenue"
      expect(page).to have_text "Fee"
      expect(page).to have_text "Provision"
      expect(page).to have_text "Payback"
    end

    it "should return from list selling status page to list index page" do
      click_link "Back"
      expect(page.current_path).to eq lists_path(locale: :en)
    end

  end

  describe "list index page" do
    before { visit lists_path(locale: :en) }

    it "should have link to list selling status page" do
      expect(page.current_path).to eq lists_path(locale: :en)
      expect(page).to have_link("Show", 
                    href: sold_items_list_path(locale: :en, id: accepted_list))
    end

    it "should forward to list selling status page" do
      click_link "Show"
      expect(page.current_path).to eq sold_items_list_path(locale: :en, 
                                                       id: accepted_list)
    end

  end
end

