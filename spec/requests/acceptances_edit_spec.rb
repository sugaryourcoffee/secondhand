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

    it "should have title Acceptance" do
      page.should have_title "Acceptance"
    end

    it "should have selector Acceptance" do
      page.should have_selector('h1', text: 'Acceptance')
    end

    it "should select a list" do
      page.should have_text "List #{list.list_number}"
      page.should have_text "Container"
      page.should have_text list.container
      page.should have_link "Edit"
      page.should have_text seller.first_name
      page.should have_text seller.last_name
      page.should have_text seller.street
      page.should have_text seller.zip_code
      page.should have_text seller.town
      page.should have_text seller.phone
      page.should have_text seller.email
      page.should have_text "Items"
      page.should have_text "Number"
      page.should have_text "Description"
      page.should have_text "Size"
      page.should have_text "Price"
      page.should have_link "Delete"
      page.should have_link "Edit"
      page.should have_button "Accept List"
      page.should have_link "Back to list overview"
    end

    it "should accept the list" do
      list.accepted_on.should be_nil

      click_button "Accept List"

      list.reload.accepted_on.should_not be_nil

      page.current_path.should eq acceptances_path(locale: :en)
    end

    it "should cancel the acceptance" do
      first(:link, 'Back to list overview').click

      list.accepted_on.should be_nil

      page.current_path.should eq acceptances_path(locale: :en)
    end

    context "accepted list" do

      before do
        accepted_list.items.create!(item_attributes)
        accept(accepted_list)
        visit edit_acceptance_path(locale: :en, id: accepted_list)
      end

      it "should show an accepted list" do
        accepted_list.accepted_on.should_not be_nil

        page.should_not have_link   "Edit"
        page.should_not have_link   "Delete"
        page.should_not have_button "Accept List"
        page.should     have_button "Revoke list acceptance"
      end

      it "should revoke list acceptance" do
        accepted_list.accepted_on.should_not be_nil

        first(:button, 'Revoke list acceptance').click

        page.current_path.should eq edit_acceptance_path(locale: :en, 
                                                         id: accepted_list)

        accepted_list.reload.accepted_on.should be_nil

        page.should     have_link   "Edit"
        page.should     have_link   "Delete"
        page.should     have_button "Accept List"
        page.should_not have_button "Revoke list acceptance"
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
            accepted_list.accepted_on.should_not be_nil

            accepted_list.items.first.sold?.should be_truthy # be_true

            page.should have_text 'List acceptance cannot be revoked because it contains sold items'

            page.should_not have_button 'Revoke list acceptance'
          end
        end

        context "as admin" do

          before do
            sign_in(admin)
            visit edit_acceptance_path(locale: :en, id: accepted_list)
          end

          it "should have 'Revoke list acceptance' button" do
            accepted_list.accepted_on.should_not be_nil

            accepted_list.items.first.sold?.should be_truthy # be_true

            page.should have_text 'List contains sold items! To edit the list you may revoke the list acceptance by pressing the button' 

            page.should have_button 'Revoke list acceptance'

          end

          it "should allow revoke list by admin" do
            first(:button, 'Revoke list acceptance').click

            page.current_path.should eq edit_acceptance_path(locale: :en, 
                                                             id: accepted_list)

            accepted_list.reload.accepted_on.should be_nil

            page.should     have_link   "Edit"
            page.should     have_link   "Delete"
            page.should     have_button "Accept List"
            page.should_not have_button "Revoke list acceptance"
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
        page.should_not have_button "Update"
        page.should have_text "Blinking Red"
      end

      it "should delete an item", js: true do
        item = list.items.first

        click_link "Delete"
        modal = page.driver.browser.switch_to.alert
        modal.accept
        
        page.should_not have_text item.description
        page.should_not have_text item.size
        page.should_not have_link "Delete"
        
        list.items.size.should eq 0
      end

      it "should not delete an item", js: true do
        item = list.items.first

        click_link "Delete"
        modal = page.driver.browser.switch_to.alert
        modal.dismiss
        
        page.should have_text item.description
        page.should have_text item.size
        page.should have_link "Delete"
        
        list.items.size.should eq 1
      end

      it "should edit an item", js: true do
        item = list.items.first

        click_link "edit-item-#{item.item_number}"

        fill_in "item_description", with: "The description"
        fill_in "item_size",        with: "The size"
        fill_in "item_price",       with: 1234.5
        click_button "Update"

        page.should have_text "The description"
        page.should have_text "The size"
        page.should have_text "1,234.50"
        page.should_not have_button "Update"
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
        page.should_not have_button "Update"
        page.should have_text "Blinking Red"
      end

      it "should not delete an item", js: true do
        item = accepted_list.items.first

        item.sold?.should be_truthy # be_true

        click_link "Delete"
        modal = page.driver.browser.switch_to.alert
        modal.accept
        
        page.should have_text item.description
        page.should have_text item.size
        page.should have_link "Delete"
        
        list.items.size.should eq 1
      end

      it "should not change item through edit", js: true do
        item = accepted_list.items.first

        click_link "edit-item-#{item.item_number}"

        fill_in "item_description", with: "The description"
        fill_in "item_size",        with: "The size"
        fill_in "item_price",       with: 1234.5
        click_button "Update"

        click_link "Cancel"

        page.should have_text "Item of the list"
        page.should have_text "XXL"
        page.should have_text "22.50"
        page.should_not have_button "Update"
      end

    end

  end

end
