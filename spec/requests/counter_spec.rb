require 'spec_helper'

describe "Counter" do

  before { visit counter_index_path(locale: :en) }

  describe "as regular user" do
    it "should not be able to access Counter" do
      page.current_path.should eq signin_path(locale: :en)
    end
  end

  describe "as admin user" do
    let(:admin) { FactoryGirl.create(:admin) }

  before { sign_in admin }
=begin
    before do
      sign_in admin
      visit counter_index_path(locale: :en)
    end
=end

    it "should visit the counter page" do
      page.current_path.should eq counter_index_path(locale: :en)
    end

    it "should have the title 'Counter'" do
      page.should have_selector('h1', text: 'Counter')
    end

    it "should have the h2 tag 'Cart'" do
      page.should have_selector('h2', text: 'Cart')
    end

    it "should have the h2 tag 'Statistic'" do
      page.should have_selector('h2', text: 'Statistic')
    end

    it "should have the h2 tag 'Selling'" do
      page.should have_selector('h2', text: 'Selling')
    end

    it "should have the h2 tag 'Reversal'" do
      page.should have_selector('h2', text: 'Redemption')
    end

    describe "Carts section" do
      let(:event)        { create_active_event }
      let!(:empty_cart)  { Cart.create }
      let!(:loaded_cart) { create_cart_with_line_items(event, 1) }

      before { visit counter_index_path(locale: :en) }
      
      it "should have table with cart headlines" do
        page.should have_text "Number"
        page.should have_text "Type"
        page.should have_text "Items"
      end

      it "should show no cart if all carts are empty" do
        page.should_not have_text "SALES"
        page.should_not have_text "REVERSAL"
        page.should_not have_link "Show"
      end

      it "should show only carts with line items" do
        page.should have_text "Cart (1)" 
      end

      it "should forward to carts show page and return back" do
        click_link "show cart"
        page.current_path.should eq cart_show_path(locale: :en, id: 2)
        click_link "back to counter"
        page.current_path.should eq counter_index_path(locale: :en)
      end
    end

    describe "Statistics section" do
      it "should have information about sellings and reversals"
    end

    describe "Sellings section" do
      it "should show all sellings"

      it "should show the latest selling on top"

      it "should forward to the sellings show page and return back"

      it "should have a link to print a selling"
    end

    describe "Reversals section" do
      it "should show all reversals"

      it "should show the latest reversal on top"

      it "should forward to the reversal show page and return back"

      it "should have a link to print a reversal"
    end
  end

end
