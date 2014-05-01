require 'spec_helper'

describe "Selling index page" do

  let(:admin)             { FactoryGirl.create(:admin) }
  let(:seller)            { FactoryGirl.create(:user) }
  let!(:accepted_list)    { FactoryGirl.create(:accepted, user: seller, event: event) }
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

    it "should have link to create new selling" do
      page.should have_link 'New Selling'
    end

    it "should create new selling" do
      click_link 'New Selling'
      page.current_path.should eq new_selling_path(locale: :en) 
    end

    it "should list available sellings" do
      page.should have_text selling.id
      page.should have_text selling.created_at
      page.should have_text selling.revenue.to_s
      page.should have_link 'Edit'
      page.should have_link 'Delete'
      page.should have_link 'Print'
    end

    it "should forward to edit selling page when searching for existing selling" do
      fill_in "Selling", with: selling.id
      click_button "Search"
      page.current_path.should eq edit_selling_path(locale: :en, id: selling)
    end

    it "should show warning when searching for not existing selling" do
      fill_in "Selling", with: 0
      click_button "Search"
      page.should have_text "Sorry, didn't find a selling with number 0"
    end

    it "should show edit selling page when pressing the edit link on a selling" do
      click_link "Edit"
      page.current_path.should eq edit_selling_path(locale: :en, id: selling)
    end

    it "should delete a selling and mark containing items as not sold", :js => true do
      selling_id      = selling.id
      selling_revenue = selling.revenue
      items = selling.items

      click_link "Delete"
      modal = page.driver.browser.switch_to.alert
      modal.accept
 
      items.reload.each do |item|
        item.selling_id.should be_nil
      end

      page.current_path.should eq sellings_path(locale: :en)

      page.should_not have_text selling_id
      page.should_not have_text selling_revenue
    end

    it "should show statistics of the sellings" do
      page.should have_text "Selling Statistics"
      page.should have_text "Sellings"
      page.should have_text 0 
      page.should have_text "Items"
      page.should have_text 0 
      page.should have_text "Revenue"
      page.should have_text 0
    end

  end

end

