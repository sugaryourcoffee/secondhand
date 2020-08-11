require 'spec_helper'

describe "Reversal cart pages" do
  include ItemsHelper

  let(:admin)   { FactoryGirl.create(:admin) }
  let(:seller)  { FactoryGirl.create(:user) }
  let(:list1)   { FactoryGirl.create(:accepted, user: seller, event: event) }
  let(:list2)   { FactoryGirl.create(:accepted, user: seller, event: event) }

  before do
    sign_in admin
    visit line_item_collection_carts_path(locale: :en)
  end

  it "should have title 'Redemption'" do
    expect(page).to have_title 'Redemption'
  end

  it "should have selector Redemption" do
    expect(page).to have_selector('h1', text: 'Redemption')
  end

  describe "with no active event" do
    let(:event)   { FactoryGirl.create(:event) }
    let!(:selling) { create_selling_and_items(event, list1) }

    it "should have warning about no active event" do
      expect(page).to have_text "Missing active Event"
    end

    it "should forward to events page to activate event" do
      click_link 'activate_event'
      expect(page.current_path).to eq events_path(locale: :en) 
    end

  end

  describe "with active event" do
    let(:event)   { FactoryGirl.create(:active) }
    let!(:selling) { create_selling_and_items(event, list1) }

    describe "line item collection" do

      before do
        add_items_to_list(list2)
        visit line_item_collection_carts_path(locale: :en)
      end

      it "should add line items" do
        fill_in 'List', with: list_number_for_cart(list1) # list1.list_number
        fill_in 'Item', with: list1.items.first.item_number
        click_button 'Add'

        expect(page.current_path).to eq line_item_collection_carts_path(locale: :en) 

        expect(page).to have_text list_item_number_for(list1.items.first)
        expect(page).to have_text list1.items.first.description
        expect(page).to have_text list1.items.first.size
        expect(page).to have_text list1.items.first.price
        expect(page).to have_link 'Delete'
      end

      it "should add line item only once" do
        fill_in 'List', with: list_number_for_cart(list1) # list1.list_number
        fill_in 'Item', with: list1.items.first.item_number
        click_button 'Add'

        expect(page).to have_text list_item_number_for(list1.items.first)
        expect(page).to have_text list1.items.first.description
        expect(page).to have_text list1.items.first.size
        expect(page).to have_text list1.items.first.price
        expect(page).to have_link 'Delete'

        fill_in 'List', with: list_number_for_cart(list1) # list1.list_number
        fill_in 'Item', with: list1.items.first.item_number
        click_button 'Add'

        expect(page).to have_text "Line item is already in cart"        
      end

      it "should not add line items contained in another cart" do
        cart = Cart.create(cart_type: 'REDEMPTION')
        cart.line_items << selling.line_items.first

        item = selling.line_items.first.item
        list = item.list

        fill_in 'List', with: list_number_for_cart(list) # list.list_number
        fill_in 'Item', with: item.item_number
        click_button 'Add'

        expect(page).to have_text "Line item is already in cart #{cart.id}"

        expect(page).not_to have_text list_item_number_for(item)
        expect(page).not_to have_text item.description
        expect(page).not_to have_text item.size
        expect(page).not_to have_text item.price
        expect(page).not_to have_link 'Delete'
      end

      it "should only add sold items" do
        fill_in 'List', with: list_number_for_cart(list2) # list2.list_number
        fill_in 'Item', with: list2.items.first.item_number
        click_button 'Add'

        expect(page).not_to have_text list_item_number_for(list1.items.first)
        expect(page).not_to have_text list1.items.first.description
        expect(page).not_to have_text list1.items.first.size
        expect(page).not_to have_text list1.items.first.price
        expect(page).not_to have_link 'Delete'

        expect(page).to have_text "Cannot redeem unsold item"
      end

      it "should remove but not delete line item" do
        fill_in 'List', with: list_number_for_cart(list1) # list1.list_number
        fill_in 'Item', with: list1.items.first.item_number
        click_button 'Add'

        expect(page.current_path).to eq line_item_collection_carts_path(locale: :en) 

        expect { click_link 'Delete' }.to change(LineItem, :count).by(0)

        expect(page.current_path).to eq line_item_collection_carts_path(locale: :en)

        expect(page).not_to have_text list_item_number_for(list1.items.first)
        expect(page).not_to have_text list1.items.first.description
        expect(page).not_to have_text list1.items.first.size
        expect(page).not_to have_text list1.items.first.price
        expect(page).not_to have_link 'Delete'
      end

      it "should forward to reversal check out" do
        fill_in 'List', with: list_number_for_cart(list1) # list1.list_number
        fill_in 'Item', with: list1.items.first.item_number
        click_button 'Add'

        expect(page.current_path).to eq line_item_collection_carts_path(locale: :en) 

        expect { click_button 'Check out' }.to change(Reversal, :count).by(1)
        
        expect(page.current_path).to eq check_out_reversal_path(locale: :en, 
                                                            id: Reversal.last)
      end
    end

    describe "reversal cart index page" do
      let!(:cart) { Cart.create!(cart_type: 'REDEMPTION') }
      
      before do
        sign_in admin
        visit carts_path(locale: :en)
      end

      it "should have title 'Carts'" do
        expect(page).to have_title 'Carts'
      end

      it "should have 'h1' 'Carts'" do
        expect(page).to have_selector('h1', text: 'Carts')
      end

      it "should show all carts" do
        expect(page).to have_text 'Number'
        expect(page).to have_text 'Type'
        expect(page).to have_text 'Items'
        expect(page).to have_text 'Cashier'
        expect(page).to have_link 'Show'
        expect(page).to have_link 'Delete'
        expect(page).to have_text cart.id
        expect(page).to have_text cart.cart_type
        expect(page).to have_text cart.line_items.count
      end

      it "should delete a cart but not the line items" do
        line_item = selling.line_items.first
        cart.line_items << line_item

        expect(cart.line_items).not_to be_empty

        expect { click_link "delete_cart_#{cart.id}" }.
          to change(Cart, :count).by(-1)

        expect(page.current_path).to eq carts_path(locale: :en)

        expect(page).to have_text "Successfully deleted cart #{cart.id}"

        expect(selling.reload.line_items.first).to eq line_item
      end

      it "should forward to cart's show page" do
        click_link "show_cart_#{cart.id}"
        expect(page.current_path).to eq cart_path(locale: :en, id: cart.id)
      end

    end

    describe "reversal cart show page" do
      let!(:cart) { Cart.create!(cart_type: 'REDEMPTION') }

      before do
        add_line_items_to_cart(cart, selling)
      end
      
      before do
        sign_in admin
        visit cart_path(locale: :en, id: cart.id)
      end

      it "should have title 'Cart'" do
        expect(page).to have_title "Cart"
      end

      it "should have 'h1' 'Cart' with id" do
        expect(page).to have_selector('h1', text: "Cart #{cart.id}")
        expect(page).to have_text 'Redemption'
      end

      it "should show cart's line items" do
        expect(page).to have_text 'Item'
        expect(page).to have_text 'Description'
        expect(page).to have_text 'Size'
        expect(page).to have_text 'Price'

        cart.line_items.each do |line_item|
          expect(page).to have_text list_item_number_for(line_item.item)
          expect(page).to have_text line_item.description
          expect(page).to have_text line_item.size
          expect(page).to have_text line_item.price
        end
      end

      it "should remove line item from cart but not delete line item" do
        expect(cart.line_items.size).to eq 1

        expect { click_link 'Delete' }.to change(LineItem, :count).by(0)
        
        expect(page.current_path).to eq cart_path(locale: :en, id: cart.id) 

        cart.line_items.each do |line_item|
          expect(page).not_to have_text list_item_number_for(line_item.item)
          expect(page).not_to have_text line_item.description
          expect(page).not_to have_text line_item.size
          expect(page).not_to have_text line_item.price
        end

        expect(cart.reload.line_items).to be_empty
      end

      it "should forward to carts index page" do
        click_link 'Back to carts overview'
        expect(page.current_path).to eq carts_path(locale: :en)
      end
    end

  end

end
