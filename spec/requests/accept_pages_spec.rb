require 'spec_helper'

describe "Acceptances" do

  let(:admin) { FactoryGirl.create(:admin) }
  let(:seller) { FactoryGirl.create(:user) }
  let(:event)  { FactoryGirl.create(:active) }
  let(:list)   { FactoryGirl.create(:assigned, user: seller, event: event) }

  before do
    sign_in(admin)
    visit acceptances_path(locale: :en)
  end

  context "without JavaScript" do
    it "should have title Acceptance" do
      page.should have_title "Acceptance"
    end

    it "should have selector Acceptance" do
      page.should have_selector('h1', text: 'Acceptance')
    end

    it "should select a list" do
      list.items.create!(item_attributes)

      fill_in "List", with: list.list_number
      click_button "Search"

      page.should have_text "List Number"
      page.should have_text list.list_number
      page.should have_text "Container"
      page.should have_text list.container
      page.should have_link "Edit"
      page.should have_text "Seller"
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
      page.should have_link "Cancel"
    end

    it "should accept the list" do
      list.items.create!(item_attributes)

      list.accepted_on.should be_nil

      fill_in "List", with: list.list_number
      click_button "Search"

      click_button "Accept List"

      page.should_not have_text "Container"
      page.should_not have_text list.container
      page.should_not have_text seller.first_name
      page.should_not have_button "Accept List"

      list.reload.accepted_on.should_not be_nil
    end

    it "should cancel the acceptance" do
      list.items.create!(item_attributes)

      fill_in "List", with: list.list_number
      click_button "Search"

      click_link "Cancel"

      page.should_not have_text "Container"
      page.should_not have_text list.container
      page.should_not have_text seller.first_name
      page.should_not have_button "Accept List"

      list.accepted_on.should be_nil
    end
  end

  context "JavaScript" do

    it "should change the container color", js: true do
      fill_in "List", with: list.list_number
      click_button "Search"

      click_link "Edit"
      fill_in "Container", with: "Blinking Red"
      click_button "Update"
      page.should_not have_button "Update"
      page.should have_text "Blinking Red"
    end

    it "should delete an item", js: true do
      list.items.create!(item_attributes)
      item = list.items.first

      fill_in "List", with: list.list_number
      click_button "Search"

      click_link "Delete"
      modal = page.driver.browser.switch_to.alert
      modal.accept
      
      page.should_not have_text item.description
      page.should_not have_text item.size
      page.should_not have_link "Delete"
      
      list.items.size.should eq 0
    end

    it "should not delete an item", js: true do
      list.items.create!(item_attributes)
      item = list.items.first

      fill_in "List", with: list.list_number
      click_button "Search"

      click_link "Delete"
      modal = page.driver.browser.switch_to.alert
      modal.dismiss
      
      page.should have_text item.description
      page.should have_text item.size
      page.should have_link "Delete"
      
      list.items.size.should eq 1
    end

    it "should edit an item", js: true do
      list.items.create!(item_attributes)
      item = list.items.first

      fill_in "List", with: list.list_number
      click_button "Search"

      page.find("#edit-item-#{item.item_number}").click

      fill_in "item_description", with: "The description"
      fill_in "item_size",        with: "The size"
      fill_in "item_price",       with: 1234.5
      click_button "Update"

      page.should have_text "The description"
      page.should have_text "The size"
      page.should have_text "1234.5"
      page.should_not have_button "Update"
    end

  end

end
