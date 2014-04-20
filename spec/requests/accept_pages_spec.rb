require 'spec_helper'

describe "Acceptance" do

  let(:admin) { FactoryGirl.create(:admin) }

  before do
    sign_in(admin)
    visit acceptance_path(locale: :en)
  end

  it "should have title Acceptance" do
    page.should have_title "Acceptance"
  end

  it "should have selector Acceptance" do
    page.should have_selector('h1', text: 'Acceptance')
  end

  describe "accept a list" do
    let(:seller) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:assigned, user: seller) }

    it "should select a list" do
      fill_in "Select List", with: list.list_number
      click_button "Search"

      page.should have_text "List"
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
      page.should have_button "Edit"
      page.should have_text "Items"
      page.should have_text "Item Number"
      page.should have_text "Description"
      page.should have_text "Size"
      page.should have_text "Price"
      page.should have_link "Delete"
      page.should have_link "Edit"
      page.should have_button "Accept List"
      page.should have_link "Cancel"
    end

    it "should change the container color"

    it "should change the seller's data"

    it "should delete an item"

    it "should edit an item"

    it "should accept the list"

    it "should cancel the acceptance"
  end

end
