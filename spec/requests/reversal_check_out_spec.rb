require 'spec_helper'

describe "Reversal check out page" do

  let(:event)    { FactoryGirl.create(:active) }
  let(:admin)    { FactoryGirl.create(:admin) }
  let(:seller)   { FactoryGirl.create(:user) }
  let(:list)     { FactoryGirl.create(:accepted, user: seller, event: event) }
  let!(:selling) { create_selling_and_items(event, list) }

  before do
    sign_in admin
    visit line_item_collection_carts_path(locale: :en)
  end

  it "should show the reversal data" do
    fill_in 'List', with: list.list_number
    fill_in 'Item', with: list.items.first.item_number
    click_button 'Add'

    page.current_path.should eq line_item_collection_carts_path(locale: :en) 

    expect { click_button 'Check out' }.to change(Reversal, :count).by(1)
        
    page.current_path.should eq check_out_reversal_path(locale: :en, 
                                                        id: Reversal.last)

    page.should have_title    "Redemption #{Reversal.last.id}"
    page.should have_selector 'h1', "Redemption #{Reversal.last.id}"
    page.should have_text     "Voucher"
    page.should have_text     "Redemption number"
    page.should have_text     "Total"

    page.should have_link "Start new redemption"
    page.should have_link "Go to redemption overview"
  end

  it "should forward to reversal index page" do
    fill_in 'List', with: list.list_number
    fill_in 'Item', with: list.items.first.item_number
    click_button 'Add'

    page.current_path.should eq line_item_collection_carts_path(locale: :en) 

    expect { click_button 'Check out' }.to change(Reversal, :count).by(1)
        
    page.current_path.should eq check_out_reversal_path(locale: :en, 
                                                        id: Reversal.last)

    click_link 'Go to redemption overview'
    page.current_path.should eq reversals_path(locale: :en)
  end

  it "should forward to cart" do
    fill_in 'List', with: list.list_number
    fill_in 'Item', with: list.items.first.item_number
    click_button 'Add'

    page.current_path.should eq line_item_collection_carts_path(locale: :en) 

    expect { click_button 'Check out' }.to change(Reversal, :count).by(1)
        
    page.current_path.should eq check_out_reversal_path(locale: :en, 
                                                        id: Reversal.last)

    click_link 'Start new redemption'
    page.current_path.should eq line_item_collection_carts_path(locale: :en)
  end
 
end
