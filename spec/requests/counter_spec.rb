require 'spec_helper'

describe "Counter" do

  let!(:event)        { create_active_event }

  before { visit counter_index_path(locale: :en) }

  describe "as regular user" do
    it "should not be able to access Counter" do
      expect(page.current_path).to eq signin_path(locale: :en)
    end
  end

  describe "as admin user" do
    let(:admin) { FactoryGirl.create(:admin) }

    before { sign_in admin }

    it "should visit the counter page" do
      expect(page.current_path).to eq counter_index_path(locale: :en)
    end

    it "should have the title 'Counter'" do
      expect(page).to have_selector('h1', text: 'Counter')
    end

    it "should have the h2 tag 'Cart'" do
      expect(page).to have_selector('h2', text: 'Cart')
    end

    it "should have the h2 tag 'Statistic'" do
      expect(page).to have_selector('h2', text: 'Statistic')
    end

    it "should have the h2 tag 'Selling'" do
      expect(page).to have_selector('h2', text: 'Selling')
    end

    it "should have the h2 tag 'Reversal'" do
      expect(page).to have_selector('h2', text: 'Redemption')
    end

    describe "with empty carts" do
      let!(:empty_cart)  { Cart.create }

      before { visit counter_index_path(locale: :en) }
      
      it "should have table with cart headlines" do
        expect(page).to have_text "Number"
        expect(page).to have_text "Type"
        expect(page).to have_text "Items"
      end

      it "should show no cart if all carts are empty" do
        expect(page).not_to have_text "SALES"
        expect(page).not_to have_text "REVERSAL"
        expect(page).not_to have_link "Show"
      end
    end

    describe "with loaded carts" do
      let!(:loaded_cart) { create_cart_with_line_items(event, 1) }
      
      before { visit counter_index_path(locale: :en) }
      
      it "should show only carts with line items" do
        expect(page).to have_text "Cart (1)" 
      end

      it "should forward to carts show page and return back" do
        click_link "Show"
        expect(page.current_path).to eq cart_path(locale: :en, id: loaded_cart)
        click_link "Back to carts overview"
        expect(page.current_path).to eq counter_index_path(locale: :en)
      end
    end

    describe "Statistics section" do
      it "should have information about sellings and reversals" do
        expect(page).to have_text "Sellings"
        expect(page).to have_text "Reversals"
        expect(page).to have_text "Count"
        expect(page).to have_text "Items"
        expect(page).to have_text "Transaction Amount"
        expect(page).to have_text "Total"
      end
    end

    describe "Sellings section" do
      let!(:selling) { create_selling(event) }

      before { visit counter_index_path(locale: :en) }
      
      it "should have selling headings" do
        expect(page).to have_text "Selling (1)"
        expect(page).to have_text "Selling"
        expect(page).to have_text "Created"
        expect(page).to have_text "Revenue"
      end

      it "should show all sellings" do
        expect(page).to have_text selling.id
        expect(page).to have_text local_date_and_time selling.created_at
        expect(page).to have_text selling.total
        expect(page).to have_link 'Show', selling_path(locale: :en, id: selling)
        expect(page).to have_link 'Print', 
                              print_selling_path(locale: :en, id: selling)
      end

      it "should filter on selling id" do
        second_selling = create_selling(event, 2)
        fill_in "selling_id", with: second_selling.id
        click_button "search_selling"
        expect(page).to     have_text second_selling.total
        expect(page).not_to have_text selling.total 
      end

      it "should forward to the sellings show page and return back" do
        click_link 'Show'
        expect(page.current_path).to eq selling_path(locale: :en, id: selling)
        click_link 'Back to Sellings'
        expect(page.current_path).to eq counter_index_path(locale: :en)
      end
    end

    describe "Reversals section" do
      let!(:reversal) { create_reversal(event) }
      
      before { visit counter_index_path(locale: :en) }

      it "should show all reversals" do
        expect(page).to have_text "Redemption (1)"
        expect(page).to have_text "Reversal"
        expect(page).to have_text "Created"
        expect(page).to have_text "Redemption"
      end

      it "should forward to the reversal show page and return back" do
        expect(page).to have_text reversal.id
        expect(page).to have_text local_date_and_time reversal.created_at
        expect(page).to have_text reversal.total
        expect(page).to have_link 'Show', reversal_path(locale: :en, id: reversal)
        expect(page).to have_link 'Print', 
                              print_reversal_path(locale: :en, id: reversal)
      end

      it "should filter on reversal id" do
        second_reversal = create_reversal(event, nil, 0, 2)
        fill_in "reversal_id", with: second_reversal.id
        click_button "search_reversal"
        expect(page).to     have_text second_reversal.total
        expect(page).not_to have_text reversal.total 
      end

      it "should forward to the reversals show page and return back" do
        click_link "show_reversal_#{reversal.id}"
        expect(page.current_path).to eq reversal_path(locale: :en, id: reversal)
        click_link "Back to Redemptions"
        expect(page.current_path).to eq counter_index_path(locale: :en)
      end
    end
  end

end
