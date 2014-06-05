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
      page.should have_title 'Selling'   
    end

    it "should have selector Selling" do
      page.should have_text 'Selling'
    end

    it "should have warning about no active event" do
      page.should have_text "For selling it is neccessary to have an active event"
      page.should have_link "activate_event"
      click_link "activate_event"
      current_path.should eq events_path(locale: :en)
    end
  end

  context "with active event" do

    let!(:event) { FactoryGirl.create(:active) }

    before do
      sign_in(admin)
      visit sellings_path(locale: :en)
    end
 
    it "should have title Selling" do
      page.should have_title 'Selling'   
    end

    it "should have selector Selling" do
      page.should have_text 'Selling'
    end

    it "should have link to forward to cart" do
      page.should have_link 'Go to cart'
    end

    it "should forward to cart" do
      click_link 'Go to cart'
      page.current_path.should eq item_collection_carts_path(locale: :en) 
    end

    it "should list available sellings" do
      page.should have_text selling.id
      page.should have_text selling.created_at
      page.should have_text selling.total.to_s
      page.should have_link 'Show'
      page.should have_link 'Delete'
      page.should have_link 'Print'
    end

    it "should forward to selling show page when searching for existing selling" do
      fill_in "Selling", with: selling.id
      click_button "Search"
      page.current_path.should eq selling_path(locale: :en, id: selling)
    end

    it "should show warning when searching for not existing selling" do
      fill_in "Selling", with: 0
      click_button "Search"
      page.should have_text "Sorry, didn't find a selling with number 0"
    end

    it "should forward to show selling page when pressing the show link on a selling" do
      click_link "Show"
      page.current_path.should eq selling_path(locale: :en, id: selling)
    end

    it "should not delete a selling with items", :js => true do
      selling_id      = selling.id
      selling_revenue = selling.total
      items = selling.line_items

      click_link "Delete"
      modal = page.driver.browser.switch_to.alert
      modal.accept
 
      page.current_path.should eq sellings_path(locale: :en)

      page.should have_text selling_id
      page.should have_text selling_revenue

      items.reload.each do |item|
        item.selling_id.should_not be_nil
      end
    end

    it "should show statistics of the sellings" do
      page.should have_text "Selling Statistics"
      page.should have_text "Sellings"
      page.should have_text 0 
      page.should have_text "Sold items"
      page.should have_text 0 
      page.should have_text "revenue per selling"
      page.should have_text 0
      page.should have_text "Revenue"
      page.should have_text 0
    end

  end

end

