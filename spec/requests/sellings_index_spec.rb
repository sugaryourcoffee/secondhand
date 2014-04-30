require 'spec_helper'

describe "Selling index page" do

  let(:admin)             { FactoryGirl.create(:admin) }
  let(:seller)            { FactoryGirl.create(:user) }
  let!(:selling)          { create_selling_and_items(1, event) }
  let!(:accepted_list)    { FactoryGirl.create(:accepted, user: seller, event: event) }

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
      page.should have_text selling.revenue
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

    it "should show edit selling page when pressing the edit link on a selling"

    it "should delete a selling and mark containing items as not sold"

    it "should show statistics of the sellings"

    it "should have a print button at each selling"

  end

end

