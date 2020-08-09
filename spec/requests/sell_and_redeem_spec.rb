require 'spec_helper'

describe "Sell and redeem" do

  let(:admin) { FactoryGirl.create(:admin) }
  let(:event) { FactoryGirl.create(:active) }
  let(:list)  { FactoryGirl.create(:accepted, user: admin, event: event) }

  before do
    add_items_to_list(list, 2)
  end

  it "should indicate redeemed items in selling" do
    sign_in admin

    click_link "Cart"

    fill_in "List", with: list_number_for_cart(list) # list.list_number
    fill_in "Item", with: list.items.first.item_number

    expect { click_button "Add" }.to change(LineItem, :count).by(1)

    expect(page).to have_text list.items.first.description

    fill_in "List", with: list_number_for_cart(list) # list.list_number
    fill_in "Item", with: list.items.last.item_number

    expect { click_button "Add" }.to change(LineItem, :count).by(1)

    expect(page).to have_text list.items.last.description

    expect { click_button "Check out" }.to change(Selling, :count).by(1)
    
    click_link "Sellings"

    expect(page).to have_text Selling.last.total

    click_link "Redemption"

    fill_in "List", with: list_number_for_cart(list) # list.list_number
    fill_in "Item", with: list.items.first.item_number

    click_button "Add"

    expect(page).to have_text list.items.first.description

    expect { click_button "Check out" }.to change(Reversal, :count).by(1)

    click_link "Sellings"

    click_link "Show"

    expect(Selling.last.total).to eq list.items.last.price

    expect(page).to have_text list.items.last.price
  end

end
