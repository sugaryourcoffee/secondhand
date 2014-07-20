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

    fill_in "List", with: list.list_number
    fill_in "Item", with: list.items.first.item_number

    expect { click_button "Add" }.to change(LineItem, :count).by(1)

    page.should have_text list.items.first.description

    fill_in "List", with: list.list_number
    fill_in "Item", with: list.items.last.item_number

    expect { click_button "Add" }.to change(LineItem, :count).by(1)

    page.should have_text list.items.last.description

    expect { click_button "Check out" }.to change(Selling, :count).by(1)
    
    click_link "Sellings"

    page.should have_text Selling.last.total

    click_link "Reversal"

    fill_in "List", with: list.list_number
    fill_in "Item", with: list.items.first.item_number

    click_button "Add"

    page.should have_text list.items.first.description

    expect { click_button "Check out" }.to change(Reversal, :count).by(1)

    click_link "Sellings"

    click_link "Show"

    Selling.last.total.should eq list.items.last.price

    page.should have_text list.items.last.price
  end

  it "should show revenue without redeemed item price"

end
