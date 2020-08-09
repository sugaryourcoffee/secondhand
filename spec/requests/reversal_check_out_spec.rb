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
    fill_in 'List', with: list_number_for_cart(list) # list.list_number
    fill_in 'Item', with: list.items.first.item_number
    click_button 'Add'

    expect(page.current_path).to eq line_item_collection_carts_path(locale: :en) 

    expect { click_button 'Check out' }.to change(Reversal, :count).by(1)
        
    expect(page.current_path).to eq check_out_reversal_path(locale: :en, 
                                                        id: Reversal.last)

    expect(page).to have_title    "Redemption #{Reversal.last.id}"
    expect(page).to have_selector 'h1', "Redemption #{Reversal.last.id}"
    expect(page).to have_text     "Voucher"
    expect(page).to have_text     "Redemption number"
    expect(page).to have_text     "Total"

    expect(page).to have_link "Start new redemption"
    expect(page).to have_link "Start selling"
    expect(page).to have_link "Go to counter"
    expect(page).not_to have_link "Go to redemption overview"
  end

  it "should forward to counter page" do
    fill_in 'List', with: list_number_for_cart(list) # list.list_number
    fill_in 'Item', with: list.items.first.item_number
    click_button 'Add'

    expect(page.current_path).to eq line_item_collection_carts_path(locale: :en) 

    expect { click_button 'Check out' }.to change(Reversal, :count).by(1)
        
    expect(page.current_path).to eq check_out_reversal_path(locale: :en, 
                                                        id: Reversal.last)

    click_link 'Go to counter'
    expect(page.current_path).to eq counter_index_path(locale: :en)
  end

  it "should forward to new redemption cart" do
    fill_in 'List', with: list_number_for_cart(list) # list.list_number
    fill_in 'Item', with: list.items.first.item_number
    click_button 'Add'

    expect(page.current_path).to eq line_item_collection_carts_path(locale: :en) 

    expect { click_button 'Check out' }.to change(Reversal, :count).by(1)
        
    expect(page.current_path).to eq check_out_reversal_path(locale: :en, 
                                                        id: Reversal.last)

    click_link 'Start new redemption'
    expect(page.current_path).to eq line_item_collection_carts_path(locale: :en)
  end

  it "should have a 'Start selling' link" do
    fill_in 'List', with: list_number_for_cart(list) # list.list_number
    fill_in 'Item', with: list.items.first.item_number
    click_button 'Add'

    expect(page.current_path).to eq line_item_collection_carts_path(locale: :en) 

    expect { click_button 'Check out' }.to change(Reversal, :count).by(1)
        
    expect(page.current_path).to eq check_out_reversal_path(locale: :en, 
                                                        id: Reversal.last)

    click_link 'Start selling'
    expect(page.current_path).to eq item_collection_carts_path(locale: :en)
  end
 
end
