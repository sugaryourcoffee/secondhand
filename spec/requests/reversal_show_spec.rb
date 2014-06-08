require 'spec_helper'

describe "Reversal show page" do
  include ItemsHelper

  let(:event)         { FactoryGirl.create(:active) }
  let(:admin)         { FactoryGirl.create(:admin) }
  let(:seller)        { FactoryGirl.create(:user) }
  let(:accepted_list) { FactoryGirl.create(:accepted, event: event, user:seller) }
  let(:selling)       { create_selling_and_items(event, accepted_list) }
  let(:reversal)      { create_reversal(event, selling, 0, 1) }

  before do
    sign_in admin
    visit reversal_path(locale: :en, id: reversal)
  end

  it "should have title 'Reversal'" do
    page.should have_title 'Redemption'
  end

  it "should have headline 'Reversal #'" do
    page.should have_selector 'h1', "Redemption #{selling.id}"
  end

  it "should have information about the reversal" do
    page.should have_text "Redemption Status"
    page.should have_text "Item count"
    page.should have_text reversal.line_items.count
    page.should have_text "Total"
    page.should have_text reversal.total
  end

  it "should have a button to forward to reversal index page" do
    page.should have_link "Back to Redemptions"
  end

  it "should show the items" do
    page.should have_text "Item"
    page.should have_text "Selling"
    page.should have_text "Description"
    page.should have_text "Size"
    page.should have_text "Price"
    page.should have_text list_item_number_for(reversal.line_items.first.item)
    page.should have_text reversal.line_items.first.selling.id
    page.should have_text reversal.line_items.first.description
    page.should have_text reversal.line_items.first.size
    page.should have_text reversal.line_items.first.price
  end

end

