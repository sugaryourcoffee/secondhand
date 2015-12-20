require 'spec_helper'

describe Cart do
  include ItemsHelper

  let(:admin)   { FactoryGirl.create(:admin) }
  let(:seller)  { FactoryGirl.create(:user) }
  let!(:event)  { FactoryGirl.create(:active) }
  let(:list1)   { FactoryGirl.create(:accepted, user: seller, event: event) }
  let(:list2)   { FactoryGirl.create(:accepted, user: seller, event: event) }

  describe "with no active event" do
    before do
      sign_in admin
      event.update(active: false)
      visit item_collection_carts_path(locale: :en)
    end

    it "should indicate missing active event" do
      event.active.should be_falsey
      page.should have_text "Missing active Event"
    end
  end

  describe "item collection page" do

    before do
      sign_in admin
      visit item_collection_carts_path(locale: :en)
    end

    before do
      add_items_to_list(list1, 3)
      add_items_to_list(list2, 3)
    end

    it "should have title 'Cart'" do
      page.should have_title 'Cart'
    end

    it "should have 'h1' 'Cart'" do
      page.should have_selector 'h1', 'Cart'
    end

    it "should add item" do
      fill_in 'List', with: list1.list_number
      fill_in 'Item', with: list1.items.first.item_number
      click_button 'Add'

      page.current_path.should eq item_collection_carts_path(locale: :en) 

      page.should have_text list_item_number_for(list1.items.first)
      page.should have_text list1.items.first.description
      page.should have_text list1.items.first.size
      page.should have_text list1.items.first.price
      page.should have_link 'Delete'
    end

    it "should delete item" do
      fill_in 'List', with: list1.list_number
      fill_in 'Item', with: list1.items.first.item_number
      click_button 'Add'

      page.current_path.should eq item_collection_carts_path(locale: :en) 

      click_link 'Delete'

      page.should_not have_text list_item_number_for(list1.items.first)
      page.should_not have_text list1.items.first.description
      page.should_not have_text list1.items.first.size
      page.should_not have_text list1.items.first.price
      page.should_not have_link 'Delete'
    end

    it "should not add empty item" do
      expect { click_button 'Add' }.to change(LineItem, :count).by(0)
    end

    it "should not add item already in the cart" do
      fill_in 'List', with: list1.list_number
      fill_in 'Item', with: list1.items.first.item_number
      click_button 'Add'
      
      fill_in 'List', with: list1.list_number
      fill_in 'Item', with: list1.items.first.item_number
      click_button 'Add'

      page.should have_text "Could not add item"
      page.should have_text "Item is already in the cart"
    end

    it "should not add item contained in another cart" do
      cart = Cart.create
      line_item = cart.add(list1.items.first)
      line_item.save

      fill_in 'List', with: list1.list_number
      fill_in 'Item', with: list1.items.first.item_number
      click_button 'Add'

      page.should have_text "Could not add item"
      page.should have_text "Item is already in cart #{cart.id}"

      page.should_not have_text list_item_number_for(list1.items.first)
      page.should_not have_text list1.items.first.description
      page.should_not have_text list1.items.first.size
      page.should_not have_text list1.items.first.price
      page.should_not have_link 'Delete'
    end

    it "should not add sold item" do
      selling = create_selling_and_items(event, list1)      
      
      fill_in 'List', with: list1.list_number
      fill_in 'Item', with: list1.items.first.item_number
      click_button 'Add'

      page.should have_text "Could not add item"
      page.should have_text "Item is already sold with selling #{selling.id}"
    end

    it "should check out, create selling and empty cart" do
      fill_in 'List', with: list1.list_number
      fill_in 'Item', with: list1.items.first.item_number
      click_button 'Add'

      page.should have_text list_item_number_for(list1.items.first)
      page.should have_text list1.items.first.description
      page.should have_text list1.items.first.size
      page.should have_text list1.items.first.price
      page.should have_link 'Delete'

      expect { click_button 'Check out' }.to change(Selling, :count).by(1)
      
      page.current_path.should eq check_out_selling_path(locale: :en, id: Selling.last)
    end
  end

  describe "index page" do

    let!(:cart) { Cart.create }

    before do
      sign_in admin
      visit carts_path(locale: :en)
    end

    before do
      add_items_to_list(list1, 1)
    end

    it "should have title 'Cart'" do
      page.should have_title 'Carts'
    end

    it "should have 'h1' 'Cart'" do
      page.should have_selector 'h1', 'Carts'
    end

    it "should show all carts" do
      page.should have_text 'Cart'
      page.should have_text 'Items'
      page.should have_text 'Cashier'
      page.should have_link 'Show'
      page.should have_link 'Delete'
      page.should have_text cart.id
      page.should have_text cart.line_items.count
    end

    it "should delete a cart" do
      line_item = cart.add(list1.items.first)
      line_item.save

      cart.line_items.should_not be_empty

      expect { click_link 'Delete' }.to change(Cart, :count).by(-1)

      page.current_path.should eq carts_path(locale: :en)

      page.should have_text "Successfully deleted cart #{cart.id}"
    end

  end

  describe "show page" do

    let(:cart) { Cart.create }

    before do
      add_items_to_list(list1, 3)
      add_items_to_cart(cart, list1)
    end

    before do
      sign_in admin
      visit cart_path(locale: :en, id: cart)
    end

    it "should have title edit cart" do
      page.should have_title 'Cart'
    end

    it "should have selector edit cart #" do
      page.should have_selector 'h1', "Cart #{cart.id}"
    end
    
    it "should have information about the cart" do
      page.should have_text 'Cart number'
      page.should have_text cart.id
      page.should have_text 'Items'
      page.should have_text cart.line_items.size
      page.should have_text 'Total'
      page.should have_text cart.total
    end

    it "should show the items" do
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

    it "should delete an item" do
      expect { click_link "delete-item-#{cart.line_items.first.id}" }.
        to change(LineItem, :count).by(-1)
    end

  end
 
end
