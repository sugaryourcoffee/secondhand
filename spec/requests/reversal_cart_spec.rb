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
    page.should have_title 'Redemption'
  end

  it "should have selector Redemption" do
    page.should have_selector 'h1', 'Redemption'
  end

  describe "with no active event" do
    let(:event)   { FactoryGirl.create(:event) }
    let!(:selling) { create_selling_and_items(event, list1) }

    it "should have warning about no active event" do
      page.should have_text "Missing active Event"
    end

    it "should forward to events page to activate event" do
      click_link 'activate_event'
      page.current_path.should eq events_path(locale: :en) 
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
        fill_in 'List', with: list1.list_number
        fill_in 'Item', with: list1.items.first.item_number
        click_button 'Add'

        page.current_path.should eq line_item_collection_carts_path(locale: :en) 

        page.should have_text list_item_number_for(list1.items.first)
        page.should have_text list1.items.first.description
        page.should have_text list1.items.first.size
        page.should have_text list1.items.first.price
        page.should have_link 'Delete'
      end

      it "should add line item only once" do
        fill_in 'List', with: list1.list_number
        fill_in 'Item', with: list1.items.first.item_number
        click_button 'Add'

        page.should have_text list_item_number_for(list1.items.first)
        page.should have_text list1.items.first.description
        page.should have_text list1.items.first.size
        page.should have_text list1.items.first.price
        page.should have_link 'Delete'

        fill_in 'List', with: list1.list_number
        fill_in 'Item', with: list1.items.first.item_number
        click_button 'Add'

        page.should have_text "Line item is already in cart"        
      end

      it "should not add line items contained in another cart" do
        cart = Cart.create(cart_type: 'REDEMPTION')
        cart.line_items << selling.line_items.first
        #cart.save

        item = selling.line_items.first.item
        list = item.list

        fill_in 'List', with: list.list_number
        fill_in 'Item', with: item.item_number
        click_button 'Add'

        page.should have_text "Line item is already in cart #{cart.id}"

        page.should_not have_text list_item_number_for(item)
        page.should_not have_text item.description
        page.should_not have_text item.size
        page.should_not have_text item.price
        page.should_not have_link 'Delete'
      end

      it "should only add sold items" do
        fill_in 'List', with: list2.list_number
        fill_in 'Item', with: list2.items.first.item_number
        click_button 'Add'

        page.should_not have_text list_item_number_for(list1.items.first)
        page.should_not have_text list1.items.first.description
        page.should_not have_text list1.items.first.size
        page.should_not have_text list1.items.first.price
        page.should_not have_link 'Delete'

        page.should have_text "Cannot redeem unsold item"
      end

      it "should remove but not delete line item" do
        fill_in 'List', with: list1.list_number
        fill_in 'Item', with: list1.items.first.item_number
        click_button 'Add'

        page.current_path.should eq line_item_collection_carts_path(locale: :en) 

        expect { click_link 'Delete' }.to change(LineItem, :count).by(0)

        page.current_path.should eq line_item_collection_carts_path(locale: :en)

        page.should_not have_text list_item_number_for(list1.items.first)
        page.should_not have_text list1.items.first.description
        page.should_not have_text list1.items.first.size
        page.should_not have_text list1.items.first.price
        page.should_not have_link 'Delete'
      end

      it "should forward to reversal check out" do
        fill_in 'List', with: list1.list_number
        fill_in 'Item', with: list1.items.first.item_number
        click_button 'Add'

        page.current_path.should eq line_item_collection_carts_path(locale: :en) 

        expect { click_button 'Check out' }.to change(Reversal, :count).by(1)
        
        page.current_path.should eq check_out_reversal_path(locale: :en, 
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
        page.should have_title 'Carts'
      end

      it "should have 'h1' 'Carts'" do
        page.should have_selector 'h1', 'Carts'
      end

      it "should show all carts" do
        page.should have_text 'Number'
        page.should have_text 'Type'
        page.should have_text 'Items'
        page.should have_text 'Cashier'
        page.should have_link 'Show'
        page.should have_link 'Delete'
        page.should have_text cart.id
        page.should have_text cart.cart_type
        page.should have_text cart.line_items.count
      end

      it "should delete a cart but not the line items" do
        line_item = selling.line_items.first
        cart.line_items << line_item
        #cart.save

        cart.line_items.should_not be_empty

        expect { click_link "delete_cart_#{cart.id}" }.
          to change(Cart, :count).by(-1)

        page.current_path.should eq carts_path(locale: :en)

        page.should have_text "Successfully deleted cart #{cart.id}"

        selling.reload.line_items.first.should eq line_item
      end

      it "should forward to cart's show page" do
        click_link "show_cart_#{cart.id}"
        page.current_path.should eq cart_path(locale: :en, id: cart.id)
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
        page.should have_title "Cart"
      end

      it "should have 'h1' 'Cart' with id" do
        page.should have_selector 'h1', "Cart #{cart.id}"
        page.should have_text 'Redemption'
      end

      it "should show cart's line items" do
        page.should have_text 'Item'
        page.should have_text 'Description'
        page.should have_text 'Size'
        page.should have_text 'Price'

        cart.line_items.each do |line_item|
          page.should have_text list_item_number_for(line_item.item)
          page.should have_text line_item.description
          page.should have_text line_item.size
          page.should have_text line_item.price
        end
      end

      it "should remove line item from cart but not delete line item" do
        cart.line_items.size.should eq 1

        expect { click_link 'Delete' }.to change(LineItem, :count).by(0)
        
        page.current_path.should eq cart_path(locale: :en, id: cart.id) 

        cart.line_items.each do |line_item|
          page.should_not have_text list_item_number_for(line_item.item)
          page.should_not have_text line_item.description
          page.should_not have_text line_item.size
          page.should_not have_text line_item.price
        end

        cart.reload.line_items.should be_empty
      end

      it "should forward to carts index page" do
        click_link 'Back to carts overview'
        page.current_path.should eq carts_path(locale: :en)
      end
    end

  end

end
