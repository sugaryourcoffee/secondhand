require 'spec_helper'

describe "Counter" do

  let!(:event)        { create_active_event }

  before { visit counter_index_path(locale: :en) }

  describe "as regular user" do
    it "should not be able to access Counter" do
      page.current_path.should eq signin_path(locale: :en)
    end
  end

  describe "as admin user" do
    let(:admin) { FactoryGirl.create(:admin) }

    before { sign_in admin }

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

    describe "with empty carts" do
      let!(:empty_cart)  { Cart.create }

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
    end

    describe "with loaded carts" do
      let!(:loaded_cart) { create_cart_with_line_items(event, 1) }
      
      before { visit counter_index_path(locale: :en) }
      
      it "should show only carts with line items" do
        page.should have_text "Cart (1)" 
      end

      it "should forward to carts show page and return back" do
        click_link "Show"
        page.current_path.should eq cart_path(locale: :en, id: loaded_cart)
        click_link "Back to carts overview"
        page.current_path.should eq counter_index_path(locale: :en)
      end
    end

    describe "Statistics section" do
      it "should have information about sellings and reversals" do
        page.should have_text "Sellings"
        page.should have_text "Reversals"
        page.should have_text "Count"
        page.should have_text "Items"
        page.should have_text "Transaction Amount"
        page.should have_text "Total"
      end
    end

    describe "Sellings section" do
      let!(:selling) { create_selling(event) }

      before { visit counter_index_path(locale: :en) }
      
      it "should have selling headings" do
        page.should have_text "Selling (1)"
        page.should have_text "Selling"
        page.should have_text "Created"
        page.should have_text "Revenue"
      end

      it "should show all sellings" do
        page.should have_text selling.id
        page.should have_text selling.created_at
        page.should have_text selling.total
        page.should have_link 'Show', selling_path(locale: :en, id: selling)
        page.should have_link 'Print', 
                              print_selling_path(locale: :en, id: selling)
      end

      it "should filter on selling id" do
        second_selling = create_selling(event, 2)
        fill_in "selling_id", with: second_selling.id
        click_button "search_selling"
        page.should     have_text second_selling.total
        page.should_not have_text selling.total 
      end

      it "should forward to the sellings show page and return back" do
        click_link 'Show'
        page.current_path.should eq selling_path(locale: :en, id: selling)
        click_link 'Back to Sellings'
        page.current_path.should eq counter_index_path(locale: :en)
      end
    end

    describe "Reversals section" do
      let!(:reversal) { create_reversal(event) }
      
      before { visit counter_index_path(locale: :en) }

      it "should show all reversals" do
        page.should have_text "Redemption (1)"
        page.should have_text "Reversal"
        page.should have_text "Created"
        page.should have_text "Redemption"
      end

      it "should forward to the reversal show page and return back" do
        page.should have_text reversal.id
        page.should have_text reversal.created_at
        page.should have_text reversal.total
        page.should have_link 'Show', reversal_path(locale: :en, id: reversal)
        page.should have_link 'Print', 
                              print_reversal_path(locale: :en, id: reversal)
      end

      it "should filter on reversal id" do
        second_reversal = create_reversal(event, nil, 0, 2)
        fill_in "reversal_id", with: second_reversal.id
        click_button "search_reversal"
        page.should     have_text second_reversal.total
        page.should_not have_text reversal.total 
      end

      it "should forward to the reversals show page and return back" do
        click_link "show_reversal_#{reversal.id}"
        page.current_path.should eq reversal_path(locale: :en, id: reversal)
        click_link "Back to Redemptions"
        page.current_path.should eq counter_index_path(locale: :en)
      end
    end
  end

end
