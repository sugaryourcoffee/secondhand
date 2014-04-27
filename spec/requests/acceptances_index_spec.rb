require 'spec_helper'

describe "Acceptances index page" do

  let(:admin)          { FactoryGirl.create(:admin) }
  let(:seller)         { FactoryGirl.create(:user) }
  let!(:list)          { FactoryGirl.create(:assigned, user: seller, event: event) }
  let!(:accepted_list) { FactoryGirl.create(:accepted, user: seller, event: event) }

  context "with no active event" do
    let(:event) { FactoryGirl.create(:event) }

    before do
      sign_in(admin)
      visit acceptances_path(locale: :en)
    end

    it "should have title Acceptance" do
      page.should have_title "Acceptance"
    end

    it "should have selector Acceptance" do
      page.should have_selector('h1', text: 'Acceptance')
    end

    it "should have warning about no active event" do
      page.should have_text "For list acceptance it is neccessary to have an active event"
      page.should have_link "activate_event"
      click_link "activate_event"
      current_path.should eq events_path(locale: :en)
    end
  end

  context "with active event" do
    let!(:event) { FactoryGirl.create(:active) }

    before do
      sign_in(admin)
      visit acceptances_path(locale: :en)
    end

    it "should have title Acceptance" do
      page.should have_title "Acceptance"
    end

    it "should have selector Acceptance" do
      page.should have_selector('h1', text: 'Acceptance')
    end

    it "should have status" do
      page.should have_text "List Acceptance Status"
      page.should have_link "Accepted"
      page.should have_link "Not accepted"
      page.should have_link "Registered"
      page.should have_link "Not registered"
      page.should have_link "Total"
    end

    it "should show open lists per default" do
      page.should have_text list.list_number
      page.should have_text user_for(list)
      
      page.should have_link "Acceptance Dialog"
    end

    it "should filter not accepted lists" do
      click_link "Not accepted"
      page.should have_text list.list_number
      page.should have_text user_for(list)
      
      page.should have_link "Acceptance Dialog"
    end

    it "should filter accepted lists" do
      click_link "Accepted"
      page.should have_text accepted_list.list_number
      page.should have_text user_for(accepted_list)
      
      page.should have_button "Revoke Acceptance"
    end

    it "should filter all lists" do
      click_link "Total"
      page.should have_text accepted_list.list_number
      page.should have_text user_for(accepted_list)
      page.should have_text list.list_number
      page.should have_text user_for(list)
      
      page.should have_button "Revoke Acceptance"
      page.should have_link   "Acceptance Dialog"
    end

    it "should show the acceptance dialog when clicking on 'Acceptance Dialog'"

    it "should show accpetance dialog when searching for an open list"

    it "should show accepted list when searching for accepted list"

    it "should release an accepted list"
  end

   

end
