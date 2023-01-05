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
      expect(page).to have_title "Acceptance"
    end

    it "should have selector Acceptance" do
      expect(page).to have_selector('h1', text: 'Acceptance')
    end

    it "should have warning about no active event" do
      expect(page).to have_text "For list acceptance it is neccessary to have an active event"
      expect(page).to have_link "activate_event"
      click_link "activate_event"
      expect(current_path).to eq events_path(locale: :en)
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
        expect(page).to have_title "Acceptance"
      end

      it "should have selector Acceptance" do
        expect(page).to have_selector('h1', text: 'Acceptance')
      end

      it "should have status" do
        expect(page).to have_text "List Acceptance Status"
        expect(page).to have_link "Accepted"
        expect(page).to have_link "Not accepted"
        expect(page).to have_link "Registered"
        expect(page).to have_link "Not registered"
        expect(page).to have_link "Total"
      end

      it "should show not accepted lists per default" do
        expect(page).to have_text list.list_number
        expect(page).to have_text user_for(list)
        
        expect(page).to have_link "Acceptance Dialog"
      end

      it "should filter not accepted lists" do
        click_link "Not accepted"
        expect(page).to have_text list.list_number
        expect(page).to have_text user_for(list)
        
        expect(page).to have_link "Acceptance Dialog"
      end

      it "should filter accepted lists" do
        click_link "Accepted"
        expect(page).to have_text accepted_list.list_number
        expect(page).to have_text user_for(accepted_list)
        
        expect(page).to have_button "Revoke Acceptance"
      end

      it "should filter all lists" do
        click_link "Total"
        expect(page).to have_text accepted_list.list_number
        expect(page).to have_text user_for(accepted_list)
        expect(page).to have_text list.list_number
        expect(page).to have_text user_for(list)
        
        expect(page).to have_button "Revoke Acceptance"
        expect(page).to have_link   "Acceptance Dialog"
      end

      it "should show the acceptance dialog when clicking on 'Acceptance Dialog'"     do
        click_link "Acceptance Dialog"
        expect(page.current_path).to eq edit_acceptance_path(locale: :en, id: list)
      end

      it "should show acceptance dialog when searching for a registered list" do
        fill_in "List", with: list.list_number
        click_button "Search"
        expect(page.current_path).to eq edit_acceptance_path(locale: :en, id: list)
      end

      it 'should show acceptance dialog when scanning label', js: true do
        list.items.create!(item_attributes)
        fill_in 'List', with: barcode_encoding_for(list, list.items.first)
        # The label is scanned and directly send by having a "\n" appended
        # Capybara doesn't respect "\n" and therefore in the test the button
        # has to be pressed
        click_button 'Search'
        expect(page).to have_current_path(edit_acceptance_path(locale: :en,
                                                               id: list.id))
      end

      it "should show acceptance dialog when searching for an accepted list" do
        fill_in "List", with: accepted_list.list_number
        click_button "Search"
        expect(page.current_path).to eq edit_acceptance_path(locale: :en, 
                                                         id: accepted_list)
      end

      it "should show warning when searching for a not registered list" do
        fill_in "List", with: unregistered_list.list_number
        click_button "Search"
        expect(page.current_path).to eq acceptances_path(locale: :en)
        expect(page).to have_text "Not Accepted Lists"
        expect(page).to have_text "List #{unregistered_list.list_number} is not registered."
      end

      it "should show warning when searching for a not existing list" do
        fill_in "List", with: "123454321"
        click_button "Search"
        expect(page.current_path).to eq acceptances_path(locale: :en)
        expect(page).to have_text "Not Accepted Lists"
        expect(page).to have_text "List #{123454321} doesn't exist!"
      end

      it "should revoke acceptance of an accepted list when clicking on \
      'Revoke Acceptance'" do
        click_link "Accepted"

        expect(page).to have_text accepted_list.list_number
        expect(page).to have_text user_for(accepted_list)

        expect(accepted_list.accepted_on).not_to be_nil

        click_button "Revoke Acceptance"

        expect(accepted_list.reload.accepted_on).to be_nil

        expect(page.current_path).to eq edit_acceptance_path(locale: :en, 
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
          expect(page).to have_button "Revoke Acceptance"          
        end

      end

      context "as operator" do

        before do
          sign_in(operator)
          visit acceptances_path(locale: :en)
          click_link "Accepted" 
        end

        it "shouldn't show revoke acceptance button" do
          expect(page).not_to have_button "Revoke Acceptance"
        end

      end

    end
  end
end
