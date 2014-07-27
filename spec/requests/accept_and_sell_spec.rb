require 'spec_helper'

describe "Accept and sell" do

  let(:admin) { FactoryGirl.create(:admin) }
  let(:event) { FactoryGirl.create(:active) }
  let(:list) { FactoryGirl.create(:list, user: admin, event: event) }

  before do
    add_items_to_list(list, 2)
  end

  it "should not delete item referenced by selling in acceptance dialog" do
    sign_in admin

    click_link "Acceptance"

    page.current_path.should eq acceptances_path(locale: :en)

    click_link "Acceptance Dialog"
    
    page.current_path.should eq edit_acceptance_path(locale: :en, id: list.id)

    click_button "Accept List"

    page.current_path.should eq acceptances_path(locale: :en)

    page.should_not have_link "Acceptances Dialog"

    click_link "Cart"

    fill_in "List", with: list.items.first.list.list_number
    fill_in "Item", with: list.items.first.item_number

    expect { click_button "Add" }.to change(LineItem, :count).by(1)

    expect { click_button "Check out" }.to change(Selling, :count).by(1)

    click_link "Acceptance"

    click_link "Accepted"

    click_button "Revoke Acceptance"

    page.current_path.should eq edit_acceptance_path(locale: :en, id: list.id)

    expect { click_link "delete-item-#{list.items.first.item_number}" }.to change(Item, :count).by(0)
    
    page.current_path.should eq delete_item_acceptance_path(locale: :en, 
                                                            id: list.id)

    page.should have_text "Cannot delete sold item #{list.items.first.item_number} from list #{list.list_number}"
  end

  it "should not delete item referenced by a redemption in acceptance dialog"

  it "should not delete item referenced by a cart in acceptance dialog"

  it "should not delete item referenced by a selling in list edit page"

  it "should not delete item referenced by a redemption in list edit page"

  it "should not delete item referenced by a cart in list edit page"
end
