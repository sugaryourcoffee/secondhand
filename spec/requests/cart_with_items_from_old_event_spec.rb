require 'spec_helper'

describe "Cart" do

  let(:admin)  { FactoryGirl.create(:admin) }
  let(:event1) { FactoryGirl.create(:active) }
  let!(:event2) { FactoryGirl.create(:event) }
  let(:list1)  { FactoryGirl.create(:accepted, user: admin, event: event1) }

  before do
    add_items_to_list(list1, 1, [12.00])
    sign_in admin
  end

  describe "without items" do
    
    before do
      click_link "Events"
    end

    it "should activate event" do
      click_button "Activate"
      expect(event1.reload.active).to be_falsey
      expect(event2.reload.active).to be_truthy
    end

    it "should deactivate event" do
      click_button "Deactivate"
      expect(event1.reload.active).to be_falsey
      expect(event2.reload.active).to be_falsey
    end

    it "should print lists" do
      visit event_path(event1, locale: :en)
      click_link "Print Lists"
      begin
        expect(page).not_to have_text "Cannot print list, because cart"
      rescue
      end
    end
    
  end

  describe "with items" do
    before do
      click_link "Cart"
      fill_in "List", with: list_number_for_cart(list1) # list1.list_number
      fill_in "Item", with: list1.items.first.item_number
      click_button "Add"
      expect(page).to have_text list1.items.first.description
      expect(page).to have_text list1.items.first.size
      expect(page).to have_text list1.items.first.price
      click_link "Events"
    end

    it "should not activate new event" do
      click_button "Activate"
      expect(page)
        .to have_text "Cannot activate new event, because cart 1 contains items."
    end

    it "should not deactivate event" do
      click_button "Deactivate"
      expect(page)
        .to have_text "Cannot deactivate event, because cart 1 contains items."
    end

    it "should not print lists" do
      visit event_path(event2, locale: :en)
      click_link "Print Lists"
      begin
        expect(page)
          .to have_text "Cannot print lists, because cart 1 contains items"
      rescue
        raise "but did print list"
      end
    end
  end
end

