require 'spec_helper'

describe "selling show page" do
  include ItemsHelper

  let(:event)         { FactoryGirl.create(:active) }
  let(:admin)         { FactoryGirl.create(:admin) }
  let(:seller)        { FactoryGirl.create(:user) }
  let(:accepted_list) { FactoryGirl.create(:accepted, event: event, user:seller) }
  let(:selling)       { create_selling_and_items(event, accepted_list) }

  before do
    sign_in admin
    visit selling_path(locale: :en, id: selling)
  end

  it "should have title 'Selling'" do
    page.should have_title 'Selling'
  end

  it "should have heading 'Selling #'" do
    page.should have_selector 'h1', "Selling #{selling.id}"
  end

  it "should have information about the selling" do
    page.should have_text "Selling Statistics"
    page.should have_text "Items"
    page.should have_text selling.items.count
    page.should have_text "Revenue"
    page.should have_text selling.revenue
  end

  it "should have a button to forward to sellings index page" do
    page.should have_link "Back to selling overview"
  end

  it "should show the items" do
    page.should have_text "Item"
    page.should have_text "Description"
    page.should have_text "Size"
    page.should have_text "Price"
    page.should have_text list_item_number_for(selling.items.first)
    page.should have_text selling.items.first.description
    page.should have_text selling.items.first.size
    page.should have_text selling.items.first.price
  end

  it "should have delete buttons at each item" do
    page.should have_link "Delete"
  end

  it "should delete item from selling" do
    click_link "Delete"
    page.should_not have_text list_item_number_for(selling.items.first)
    page.should_not have_text selling.items.first.description
    page.should_not have_text selling.items.first.size
    page.should_not have_text selling.items.first.price
  end

end
