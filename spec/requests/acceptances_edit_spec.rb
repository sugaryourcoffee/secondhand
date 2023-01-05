# frozen_string_literal: true

require 'spec_helper'

describe "Acceptances" do

  let(:admin)         { FactoryGirl.create(:admin) }
  let(:operator)      { FactoryGirl.create(:operator) }
  let(:seller)        { FactoryGirl.create(:user) }
  let(:event)         { FactoryGirl.create(:active) }
  let(:list)          { FactoryGirl.create(:assigned, user: seller, 
                                           event: event) }
  let(:accepted_list) { FactoryGirl.create(:assigned, user: seller, 
                                           event: event) }

  before do
    list.items.create!(item_attributes)
  end

  context "without JavaScript" do
    before do
      sign_in(admin)
      visit edit_acceptance_path(locale: :en, id: list)
    end

    it "should have sortable item columns" do
      expect(page).to have_link "Number"
      expect(page).to have_link "Description"
      expect(page).to have_link "Size"
      expect(page).to have_link "Price"
    end

    it "should have title Acceptance" do
      expect(page).to have_title "Acceptance"
    end

    it "should have selector Acceptance" do
      expect(page).to have_selector('h1', text: 'Acceptance')
    end

    it "should select a list" do
      expect(page).to have_text "List #{list.list_number}"
      expect(page).to have_text "Container"
      expect(page).to have_text list.container
      expect(page).to have_link "Edit"
      expect(page).to have_text seller.first_name
      expect(page).to have_text seller.last_name
      expect(page).to have_text seller.street
      expect(page).to have_text seller.zip_code
      expect(page).to have_text seller.town
      expect(page).to have_text seller.phone
      expect(page).to have_text seller.email
      expect(page).to have_text "Items"
      expect(page).to have_text "Number"
      expect(page).to have_text "Description"
      expect(page).to have_text "Size"
      expect(page).to have_text "Price"
      expect(page).to have_link "Delete"
      expect(page).to have_link "Edit"
      expect(page).to have_button "Accept List"
      expect(page).to have_link "Back to list overview"
    end

    it "should accept the list" do
      expect(list.accepted_on).to be_nil

      click_button "Accept List"

      expect(list.reload.accepted_on).not_to be_nil

      expect(page.current_path).to eq acceptances_path(locale: :en)
    end

    it "should cancel the acceptance" do
      first(:link, 'Back to list overview').click

      expect(list.accepted_on).to be_nil

      expect(page.current_path).to eq acceptances_path(locale: :en)
    end

    context "accepted list" do

      before do
        accepted_list.items.create!(item_attributes)
        accept(accepted_list)
        visit edit_acceptance_path(locale: :en, id: accepted_list)
      end

      it "should show an accepted list" do
        expect(accepted_list.accepted_on).not_to be_nil

        expect(page).not_to have_link   "Edit"
        expect(page).not_to have_link   "Delete"
        expect(page).not_to have_button "Accept List"
        expect(page).to     have_button "Revoke list acceptance"
      end

      it "should revoke list acceptance" do
        expect(accepted_list.accepted_on).not_to be_nil

        first(:button, 'Revoke list acceptance').click

        expect(page.current_path).to eq edit_acceptance_path(locale: :en, 
                                                         id: accepted_list)

        expect(accepted_list.reload.accepted_on).to be_nil

        expect(page).to     have_link   "Edit"
        expect(page).to     have_link   "Delete"
        expect(page).to     have_button "Accept List"
        expect(page).not_to have_button "Revoke list acceptance"
      end

      context "with sold items" do

        before do
          create_selling_and_items(event, accepted_list) 
        end

        context "as operator" do
          before do
            sign_in(operator)
            visit edit_acceptance_path(locale: :en, id: accepted_list)
          end

          it "should not have 'Revoke list acceptance' button" do
            expect(accepted_list.accepted_on).not_to be_nil

            expect(accepted_list.items.first.sold?).to be_truthy # be_true

            expect(page).to have_text 'List acceptance cannot be revoked because it contains sold items'

            expect(page).not_to have_button 'Revoke list acceptance'
          end
        end

        context "as admin" do

          before do
            sign_in(admin)
            visit edit_acceptance_path(locale: :en, id: accepted_list)
          end

          it "should have 'Revoke list acceptance' button" do
            expect(accepted_list.accepted_on).not_to be_nil

            expect(accepted_list.items.first.sold?).to be_truthy 

            expect(page).to have_text("List contains sold items!\nTo edit the list you may revoke the list acceptance by pressing the button")

            expect(page).to have_button 'Revoke list acceptance'

          end

          it "should allow revoke list by admin" do
            first(:button, 'Revoke list acceptance').click

            expect(page.current_path).to eq edit_acceptance_path(locale: :en, 
                                                             id: accepted_list)

            expect(accepted_list.reload.accepted_on).to be_nil

            expect(page).to     have_link   "Edit"
            expect(page).to     have_link   "Delete"
            expect(page).to     have_button "Accept List"
            expect(page).not_to have_button "Revoke list acceptance"
           end

        end

      end
    end

  end

  context "JavaScript" do

    before do
      sign_in(admin)
    end

    context "with unsold items" do

      before do
        visit edit_acceptance_path(locale: :en, id: list)
      end

      it "should change the container color", js: true do
        click_link "edit_container"
        fill_in "Container", with: "Blinking Red"
        click_button "Update"
        expect(page).not_to have_button "Update"
        expect(page).to have_text "Blinking Red"
      end

      it "should delete an item", js: true do
        item = list.items.first

        click_link "Delete"
        modal = page.driver.browser.switch_to.alert
        modal.accept
        
        expect(page).to have_text(" ", wait: 5) # due to time issues
        expect(page).not_to have_text(item.description)
        expect(page).not_to have_text item.size
        expect(page).not_to have_link "Delete"
        
        expect(list.items.size).to eq 0
      end

      it "should not delete an item", js: true do
        item = list.items.first

        click_link "Delete"
        modal = page.driver.browser.switch_to.alert
        modal.dismiss
        
        expect(page).to have_text item.description
        expect(page).to have_text item.size
        expect(page).to have_link "Delete"
        
        expect(list.items.size).to eq 1
      end

      it "should edit an item", js: true do
        item = list.items.first

        click_link "edit-item-#{item.item_number}"

        fill_in "item_description", with: "The description"
        fill_in "item_size",        with: "The size"
        fill_in "item_price",       with: 1234.5
        click_button "Update"

        expect(page).to have_text "The description"
        expect(page).to have_text "The size"
        expect(page).to have_text "1,234.50"
        expect(page).not_to have_button "Update"
      end

    end

    context "with sold items" do

      before do
        create_selling_and_items(event, accepted_list) 
        visit edit_acceptance_path(locale: :en, id: accepted_list)
        first(:button, 'Revoke list acceptance').click
      end

      it "should change the container color", js: true do
        click_link "edit_container"
        fill_in "Container", with: "Blinking Red"
        click_button "Update"
        expect(page).not_to have_button "Update"
        expect(page).to have_text "Blinking Red"
      end

      it "should not delete an item", js: true do
        item = accepted_list.items.first

        expect(item.sold?).to be_truthy # be_true

        expect(page).not_to have_link "Delete"

#        click_link "Delete"
#        modal = page.driver.browser.switch_to.alert
#        modal.accept
        
#        page.should have_text item.description
#        page.should have_text item.size
#        page.should have_link "Delete"
        
#        list.items.size.should eq 1
      end

      it "should not change item through edit", js: true do
        item = accepted_list.items.first

        expect(page).not_to have_link "edit-item-#{item.item_number}"
#        click_link "edit-item-#{item.item_number}"

#        fill_in "item_description", with: "The description"
#        fill_in "item_size",        with: "The size"
#        fill_in "item_price",       with: 1234.5
#        click_button "Update"

#        click_link "Cancel"

#        page.should have_text "Item of the list"
#        page.should have_text "XXL"
#        page.should have_text "22.50"
#        page.should_not have_button "Update"
      end

    end

  end

end
