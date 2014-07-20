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
    page.should have_text "Selling Status"
    page.should have_text "Item count"
    page.should have_text selling.line_items.count
    page.should have_text "Total"
    page.should have_text selling.total
  end

  it "should have a button to forward to sellings index page" do
    page.should have_link "Back to Sellings"
  end

  it "should show the items" do
    page.should have_text "Item"
    page.should have_text "Redemption"
    page.should have_text "Description"
    page.should have_text "Size"
    page.should have_text "Price"
    page.should have_text list_item_number_for(selling.line_items.first.item)
    page.should have_text selling.line_items.first.selling_opponent
    page.should have_text selling.line_items.first.description
    page.should have_text selling.line_items.first.size
    page.should have_text selling.line_items.first.price
  end

end
