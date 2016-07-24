require 'spec_helper'

describe "Acceptances index page" do

  let(:admin)             { FactoryGirl.create(:admin) }
  let(:operator)          { FactoryGirl.create(:operator) }
  let(:seller)            { FactoryGirl.create(:user) }
  let(:unregistered_list) { FactoryGirl.create(:list, event: event) }
  let!(:list)             { FactoryGirl.create(:assigned, user: seller, 
                                               event: event) }
  let!(:accepted_list)    { FactoryGirl.create(:accepted, user: seller, 
                                               event: event) }

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
      page.should have_text "For list acceptance it is neccessary to have an \
      active event"
      page.should have_link "activate_event"
      click_link "activate_event"
      current_path.should eq events_path(locale: :en)
    end
  end

  context "with active event" do
    let!(:event) { FactoryGirl.create(:active) }

    context "with no sold items" do

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

      it "should show not accepted lists per default" do
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

      it "should show the acceptance dialog when clicking on 'Acceptance Dialog'"     do
        click_link "Acceptance Dialog"
        page.current_path.should eq edit_acceptance_path(locale: :en, id: list)
      end

      it "should show acceptance dialog when searching for a registered list" do
        fill_in "List", with: list.list_number
        click_button "Search"
        page.current_path.should eq edit_acceptance_path(locale: :en, id: list)
      end

      it "should show acceptance diaglog when scanning label", js: true do
        list.items.create!(item_attributes)
        fill_in "List", with: barcode_encoding_for(list, list.items.first)
        page.current_path.should eq edit_acceptance_path(locale: :en, id: list)
      end

      it "should show acceptance dialog when searching for an accepted list" do
        fill_in "List", with: accepted_list.list_number
        click_button "Search"
        page.current_path.should eq edit_acceptance_path(locale: :en, 
                                                         id: accepted_list)
      end

      it "should show warning when searching for a not registered list" do
        fill_in "List", with: unregistered_list.list_number
        click_button "Search"
        page.current_path.should eq acceptances_path(locale: :en)
        page.should have_text "Not Accepted Lists"
        page.should have_text "List #{unregistered_list.list_number} \
        is not registered."
      end

      it "should show warning when searching for a not existing list" do
        fill_in "List", with: "123454321"
        click_button "Search"
        page.current_path.should eq acceptances_path(locale: :en)
        page.should have_text "Not Accepted Lists"
        page.should have_text "List #{123454321} doesn't exist!"
      end

      it "should revoke acceptance of an accepted list when clicking on \
      'Revoke Acceptance'" do
        click_link "Accepted"

        page.should have_text accepted_list.list_number
        page.should have_text user_for(accepted_list)

        accepted_list.accepted_on.should_not be_nil

        click_button "Revoke Acceptance"

        accepted_list.reload.accepted_on.should be_nil

        page.current_path.should eq edit_acceptance_path(locale: :en, 
                                                         id: accepted_list)
      end

    end

    context "with sold items" do

      before { create_selling_and_items(event, accepted_list) }

      context "as admin" do

        before do
          sign_in(admin)
          visit acceptances_path(locale: :en)
          click_link "Accepted"
        end

        it "should show revoke acceptance button" do
          page.should have_button "Revoke Acceptance"          
        end

      end

      context "as operator" do

        before do
          sign_in(operator)
          visit acceptances_path(locale: :en)
          click_link "Accepted" 
        end

        it "shouldn't show revoke acceptance button" do
          page.should_not have_button "Revoke Acceptance"
        end

      end

    end
  end
end
