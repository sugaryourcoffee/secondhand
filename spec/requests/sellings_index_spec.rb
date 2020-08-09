require 'spec_helper'

describe "Selling index page" do

  let(:admin)             { FactoryGirl.create(:admin) }
  let(:seller)            { FactoryGirl.create(:user) }
  let!(:accepted_list)    { FactoryGirl.create(:accepted, user: seller, 
                                               event: event) }
  let!(:selling)          { create_selling_and_items(event, accepted_list) }

  context "with no active event" do
    let(:event) { FactoryGirl.create(:event) }

    before do
      sign_in(admin)
      visit sellings_path(locale: :en)
    end

    it "should have title Selling" do
      expect(page).to have_title 'Selling'   
    end

    it "should have selector Selling" do
      expect(page).to have_text 'Selling'
    end

    it "should have warning about no active event" do
      expect(page).to have_text "For selling it is neccessary to have an active event"
      expect(page).to have_link "activate_event"
      click_link "activate_event"
      expect(current_path).to eq events_path(locale: :en)
    end
  end

  context "with active event" do

    let!(:event) { FactoryGirl.create(:active) }

    before do
      sign_in(admin)
      visit sellings_path(locale: :en)
    end
 
    it "should have title Selling" do
      expect(page).to have_title 'Selling'   
    end

    it "should have selector Selling" do
      expect(page).to have_text 'Selling'
    end

    it "should have link to forward to cart" do
      expect(page).to have_link 'Go to cart'
    end

    it "should forward to cart" do
      click_link 'Go to cart'
      expect(page.current_path).to eq item_collection_carts_path(locale: :en) 
    end

    it "should list available sellings" do
      expect(page).to have_text selling.id
      expect(page).to have_text local_date_and_time selling.created_at
      expect(page).to have_text selling.total.to_s
      expect(page).to have_link 'Show'
      expect(page).to have_link 'Delete'
      expect(page).to have_link 'Print'
    end

    it "should forward to selling show page when searching for existing selling" do
      fill_in "Selling", with: selling.id
      click_button "Search"
      expect(page.current_path).to eq selling_path(locale: :en, id: selling)
    end

    it "should show warning when searching for not existing selling" do
      fill_in "Selling", with: 0
      click_button "Search"
      expect(page).to have_text "Sorry, didn't find a selling with number 0"
    end

    it "should forward to show selling page when pressing the show link on a selling" do
      click_link "Show"
      expect(page.current_path).to eq selling_path(locale: :en, id: selling)
    end

    it "should not delete a selling with items", :js => true do
      selling_id      = selling.id
      selling_revenue = selling.total
      items = selling.line_items

      click_link "Delete"
      modal = page.driver.browser.switch_to.alert
      modal.accept
 
      expect(page.current_path).to eq sellings_path(locale: :en)

      expect(page).to have_text selling_id
      expect(page).to have_text selling_revenue

      expect(page).to have_text "Cannot delete selling when containing items"

      items.reload.each do |item|
        expect(item.selling_id).not_to be_nil
      end
    end

    it "should show statistics of the sellings" do
      expect(page).to have_text "Selling Statistics"
      expect(page).to have_text "Sellings"
      expect(page).to have_text 0 
      expect(page).to have_text "Sold items"
      expect(page).to have_text 0 
      expect(page).to have_text "revenue per selling"
      expect(page).to have_text 0
      expect(page).to have_text "Revenue"
      expect(page).to have_text 0
    end

  end

end

