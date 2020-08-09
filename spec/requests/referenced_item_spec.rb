require 'spec_helper'

describe "Item referenced" do

  let(:admin) { FactoryGirl.create(:admin) }
  let(:event) { FactoryGirl.create(:active) }
  let(:list)  { FactoryGirl.create(:list, user: admin, event: event) }

  before do
    add_items_to_list(list, 2)

    sign_in admin

    expect(page.current_path).to eq user_path(locale: :en, id: admin)
    
    click_link "Acceptance"

    expect(page.current_path).to eq acceptances_path(locale: :en)

    click_link "Acceptance Dialog"
    
    expect(page.current_path).to eq edit_acceptance_path(locale: :en, id: list.id)

    click_button "Accept List"

    expect(page.current_path).to eq acceptances_path(locale: :en)

    expect(page).not_to have_link "Acceptances Dialog"

    click_link "Cart"

    fill_in "List", with: list_number_for_cart(list.items.first.list) # list.items.first.list.list_number
    fill_in "Item", with: list.items.first.item_number

    expect { click_button "Add" }.to change(LineItem, :count).by(1)
  end

  it "by a cart should not be deleted in acceptance dialog" do
    click_link "Acceptance"

    click_link "Accepted"

    click_button "Revoke Acceptance"

    expect(page.current_path).to eq edit_acceptance_path(locale: :en, id: list.id)

    expect { click_link "delete-item-#{list.items.first.item_number}" }.
                                                   to change(Item, :count).by(0)
    
    expect(page.current_path).to eq delete_item_acceptance_path(locale: :en, 
                                                           id: list.items.first)
  end

  it "by selling should not be deleted in acceptance dialog" do
    expect { click_button "Check out" }.to change(Selling, :count).by(1)

    click_link "Acceptance"

    click_link "Accepted"

    click_button "Revoke Acceptance"

    expect(page.current_path).to eq edit_acceptance_path(locale: :en, id: list.id)

    #replacement for below commented out
    expect(page).not_to have_button "delete-item-#{list.items.first.item_number}"

#    expect { click_link "delete-item-#{list.items.first.item_number}" }.
#                                                   to change(Item, :count).by(0)
    
#    page.current_path.should eq delete_item_acceptance_path(locale: :en, 
#                                                           id: list.items.first)
  end

  it "by a redemption should not be deleted in acceptance dialog" do
    expect { click_button "Check out" }.to change(Selling, :count).by(1)

    click_link "Redemption"

    fill_in "List", with: list_number_for_cart(list) # list.list_number
    fill_in "Item", with: list.items.first.item_number

    click_button "Add"

    expect(page.current_path).to eq line_item_collection_carts_path(locale: :en)

    expect { click_button "Check out" }.to change(Reversal, :count).by(1)

    click_link "Acceptance"

    click_link "Accepted"

    click_button "Revoke Acceptance"

    expect(page.current_path).to eq edit_acceptance_path(locale: :en, id: list.id)

    expect { click_link "delete-item-#{list.items.first.item_number}" }.
                                                   to change(Item, :count).by(0)
    
    expect(page.current_path).to eq delete_item_acceptance_path(locale: :en, 
                                                           id: list.items.first)
   end

  it "by a cart should not be deleted in user list page" do
    visit user_list_items_path(locale: :en, user_id: admin, list_id: list)

    expect { click_link "destroy_item_#{list.items.first.item_number}" }.
                                                   to change(Item, :count).by(0)
  end

  it "by a selling should not be deleted in user list page" do
    expect { click_button "Check out" }.to change(Selling, :count).by(1)

    visit user_list_items_path(locale: :en, user_id: admin, list_id: list)

    expect { click_link "destroy_item_#{list.items.first.item_number}" }.
                                                   to change(Item, :count).by(0)
  end

  it "by a redemption should not be deleted in user list page" do
    expect { click_button "Check out" }.to change(Selling, :count).by(1)

    click_link "Redemption"

    fill_in "List", with: list_number_for_cart(list) # list.list_number
    fill_in "Item", with: list.items.first.item_number

    click_button "Add"

    expect(page.current_path).to eq line_item_collection_carts_path(locale: :en)

    expect { click_button "Check out" }.to change(Reversal, :count).by(1)

    visit user_list_items_path(locale: :en, user_id: admin, list_id: list)

    expect { click_link "destroy_item_#{list.items.first.item_number}" }.
                                                   to change(Item, :count).by(0)
  end

end
