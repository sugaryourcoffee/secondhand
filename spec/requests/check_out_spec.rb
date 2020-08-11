require 'spec_helper'

describe "Selling finish page" do

  let(:event) { FactoryGirl.create(:active) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:seller) { FactoryGirl.create(:user) }
  let(:accepted_list) { FactoryGirl.create(:accepted, event: event, user: seller) }
  let(:selling)       { create_selling_and_items(event, accepted_list) }
  
  before do
    sign_in admin
    visit check_out_selling_path(locale: :en, id: selling)
  end

  it "should have title 'Selling #'" do
    expect(page).to have_title "Selling #{selling.id}"
  end

  it "should have heading 'Selling #'" do
    expect(page).to have_selector('h1', text: "Selling #{selling.id}")
  end

  it "should have information about the selling" do
    expect(page).to have_text 'Selling'
    expect(page).to have_text selling.id
    expect(page).to have_text 'Total'
    expect(page).to have_text selling.total
  end

  it "should have a 'Start new selling' button" do
    click_link 'Start new selling'
    expect(page.current_path).to eq item_collection_carts_path(locale: :en)
  end

  it "should have a 'Start redemption' link" do
    click_link 'Start redemption'
    expect(page.current_path).to eq line_item_collection_carts_path(locale: :en)
  end

  it "should have a 'Go to counter' link" do
    click_link 'Go to counter'
    expect(page.current_path).to eq counter_index_path(locale: :en)
  end

  it "should not have a 'To selling overview' link" do
    expect(page).not_to have_link 'Go to selling overview'
  end

end
