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
      expect(event.active).to be_falsey
      expect(page).to have_text "Missing active Event"
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
      expect(page).to have_title 'Cart'
    end

    it "should have 'h1' 'Cart'" do
      expect(page).to have_selector('h1', text: 'Cart')
    end

    it "should add item" do
      fill_in 'List', with: list_number_for_cart(list1) # list1.list_number
      fill_in 'Item', with: list1.items.first.item_number
      click_button 'Add'

      expect(page.current_path).to eq item_collection_carts_path(locale: :en) 

      expect(page).to have_text list_item_number_for(list1.items.first)
      expect(page).to have_text list1.items.first.description
      expect(page).to have_text list1.items.first.size
      expect(page).to have_text list1.items.first.price
      expect(page).to have_link 'Delete'
    end

    it "should delete item" do
      fill_in 'List', with: list_number_for_cart(list1) # list1.list_number
      fill_in 'Item', with: list1.items.first.item_number
      click_button 'Add'

      expect(page.current_path).to eq item_collection_carts_path(locale: :en) 

      click_link 'Delete'

      expect(page).not_to have_text list_item_number_for(list1.items.first)
      expect(page).not_to have_text list1.items.first.description
      expect(page).not_to have_text list1.items.first.size
      expect(page).not_to have_text list1.items.first.price
      expect(page).not_to have_link 'Delete'
    end

    it "should not add empty item" do
      expect { click_button 'Add' }.to change(LineItem, :count).by(0)
    end

    it "should indicated not existing list" do
      fill_in 'List', with: "#{list1.event_id}1000"
      fill_in 'Item', with: "4"
      click_button 'Add'
      expect(page).to have_text "Could not add item"
      expect(page).to have_text "List 1000 doesn't exist"
    end

    it "should indicate empty list" do
      fill_in 'List', with: ""
      fill_in 'Item', with: "4"
      click_button 'Add'
      expect(page).to have_text "Could not add item"
      expect(page).to have_text "List must not be empty"
    end

    it "should indicate not existing item" do
      fill_in 'List', with: list_number_for_cart(list1) # list1.list_number
      fill_in 'Item', with: "4"
      click_button 'Add'
      expect(page).to have_text "Could not add item"
      expect(page).to have_text "Item 4 doesn't exist"
    end

    it "should not add item already in the cart" do
      fill_in 'List', with: list_number_for_cart(list1) # list1.list_number
      fill_in 'Item', with: list1.items.first.item_number
      click_button 'Add'
      
      fill_in 'List', with: list_number_for_cart(list1) # list1.list_number
      fill_in 'Item', with: list1.items.first.item_number
      click_button 'Add'

      expect(page).to have_text "Could not add item"
      expect(page).to have_text "Item is already in the cart"
    end

    it "should not add item contained in another cart" do
      cart = Cart.create
      line_item = cart.add(list1.items.first)
      line_item.save

      fill_in 'List', with: list_number_for_cart(list1) # list1.list_number
      fill_in 'Item', with: list1.items.first.item_number
      click_button 'Add'

      expect(page).to have_text "Could not add item"
      expect(page).to have_text "Item is already in cart #{cart.id}"

      expect(page).not_to have_text list_item_number_for(list1.items.first)
      expect(page).not_to have_text list1.items.first.description
      expect(page).not_to have_text list1.items.first.size
      expect(page).not_to have_text list1.items.first.price
      expect(page).not_to have_link 'Delete'
    end

    it "should not add sold item" do
      selling = create_selling_and_items(event, list1)      
      
      fill_in 'List', with: list_number_for_cart(list1) # list1.list_number
      fill_in 'Item', with: list1.items.first.item_number
      click_button 'Add'

      expect(page).to have_text "Could not add item"
      expect(page).to have_text "Item is already sold with selling #{selling.id}"
    end

    it "should check out, create selling and empty cart" do
      fill_in 'List', with: list_number_for_cart(list1) # list1.list_number
      fill_in 'Item', with: list1.items.first.item_number
      click_button 'Add'

      expect(page).to have_text list_item_number_for(list1.items.first)
      expect(page).to have_text list1.items.first.description
      expect(page).to have_text list1.items.first.size
      expect(page).to have_text list1.items.first.price
      expect(page).to have_link 'Delete'

      expect { click_button 'Check out' }.to change(Selling, :count).by(1)
      
      expect(page.current_path).to eq check_out_selling_path(locale: :en, id: Selling.last)
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
      expect(page).to have_title 'Carts'
    end

    it "should have 'h1' 'Cart'" do
      expect(page).to have_selector('h1', text: 'Carts')
    end

    it "should show all carts" do
      expect(page).to have_text 'Cart'
      expect(page).to have_text 'Items'
      expect(page).to have_text 'Cashier'
      expect(page).to have_link 'Show'
      expect(page).to have_link 'Delete'
      expect(page).to have_text cart.id
      expect(page).to have_text cart.line_items.count
    end

    it "should delete a cart" do
      line_item = cart.add(list1.items.first)
      line_item.save

      expect(cart.line_items).not_to be_empty

      expect { click_link 'Delete' }.to change(Cart, :count).by(-1)

      expect(page.current_path).to eq carts_path(locale: :en)

      expect(page).to have_text "Successfully deleted cart #{cart.id}"
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
      expect(page).to have_title 'Cart'
    end

    it "should have selector edit cart #" do
      expect(page).to have_selector('h1', text: "Cart #{cart.id}")
    end
    
    it "should have information about the cart" do
      expect(page).to have_text 'Cart number'
      expect(page).to have_text cart.id
      expect(page).to have_text 'Items'
      expect(page).to have_text cart.line_items.size
      expect(page).to have_text 'Total'
      expect(page).to have_text cart.total
    end

    it "should show the items" do
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

    it "should delete an item" do
      expect { click_link "delete-item-#{cart.line_items.first.id}" }.
        to change(LineItem, :count).by(-1)
    end

  end
 
end
