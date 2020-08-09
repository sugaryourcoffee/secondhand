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
    expect(page).to have_title 'Redemption'
  end

  it "should have headline 'Reversal #'" do
    expect(page).to have_selector 'h1', "Redemption #{selling.id}"
  end

  it "should have information about the reversal" do
    expect(page).to have_text "Redemption Status"
    expect(page).to have_text "Item count"
    expect(page).to have_text reversal.line_items.count
    expect(page).to have_text "Total"
    expect(page).to have_text reversal.total
  end

  it "should have a button to forward to reversal index page" do
    expect(page).to have_link "Back to Redemptions"
  end

  it "should show the items" do
    expect(page).to have_text "Item"
    expect(page).to have_text "Selling"
    expect(page).to have_text "Description"
    expect(page).to have_text "Size"
    expect(page).to have_text "Price"
    expect(page).to have_text list_item_number_for(reversal.line_items.first.item)
    expect(page).to have_text reversal.line_items.first.selling.id
    expect(page).to have_text reversal.line_items.first.description
    expect(page).to have_text reversal.line_items.first.size
    expect(page).to have_text reversal.line_items.first.price
  end

end

