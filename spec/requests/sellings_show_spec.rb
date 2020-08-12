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
    expect(page).to have_title 'Selling'
  end

  it "should have heading 'Selling #'" do
    expect(page).to have_selector('h1', text: "Selling #{selling.id}")
  end

  it "should have information about the selling" do
    expect(page).to have_text "Selling Status"
    expect(page).to have_text "Item count"
    expect(page).to have_text selling.line_items.count
    expect(page).to have_text "Total"
    expect(page).to have_text selling.total
  end

  it "should have a button to forward to sellings index page" do
    expect(page).to have_link "Back to Sellings"
  end

  it "should show the items" do
    expect(page).to have_text "Item"
    expect(page).to have_text "Redemption"
    expect(page).to have_text "Description"
    expect(page).to have_text "Size"
    expect(page).to have_text "Price"
    expect(page).to have_text list_item_number_for(selling.line_items.first.item)
    # expect(page).to have_text selling.line_items.first.selling_opponent
    expect(page).to have_text selling.line_items.first.description
    expect(page).to have_text selling.line_items.first.size
    expect(page).to have_text selling.line_items.first.price
  end

end
