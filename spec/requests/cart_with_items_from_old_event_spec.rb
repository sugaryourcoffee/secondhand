require 'spec_helper'

describe "Remove items from other event from cart" do

  let(:admin)  { FactoryGirl.create(:admin) }
  let(:event1) { FactoryGirl.create(:active) }
  let(:event2) { FactoryGirl.create(:event) }
  let(:list1)  { FactoryGirl.create(:accepted, user: admin, event: event1) }
  let(:list2)  { FactoryGirl.create(:accepted, user: admin, event: event2) }

  before do
    add_items_to_list(list1, 1, [12.00])
    add_items_to_list(list2, 2, [23.50, 34.50])
  end

  it "it should delete items from other event from cart" do
    sign_in admin
    click_link "Cart"
    fill_in "List", with: "1"
    fill_in "Item", with: "1"
    click_button "Add"
    click_link "Events"
    click_button "Activate"
    visit item_collection_carts_path(locale: :en)
    expect(page).to have_text list1.items.first.description
    expect(page).to have_text list1.items.first.size
    expect(page).to have_text list1.items.first.price
    fill_in "List", with: "2"
    fill_in "Item", with: "2"
    click_button "Add"
    click_button "Check out"
    click_link "Go to counter"
    click_link "Show"
    expect(page).to have_text list2.items.second.price
    expect(page).not_to have_text list1.items.first.price
  end

end

