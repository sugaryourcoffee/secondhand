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

    it "should have the title 'Counter'" do
      page.should have_selector('h1', text: 'Counter')
    end

    it "should have the h1 tag 'Carts'" do
      page.should have_selector('h2', text: 'Carts')
    end

    it "should have the h1 tag 'Statistics'" do
      page.should have_selector('h2', text: 'Statistics')
    end

    it "should have the h1 tag 'Sellings'" do
      page.should have_selector('h2', text: 'Sellings')
    end

    it "should have the h1 tag 'Reversals'" do
      page.should have_selector('h2', text: 'Reversals')
    end

    describe "Carts section" do
      let!(:cart) { Cart.create }
      
      it "should show no cart if all carts are empty"

      it "should show only carts with line items"

      it "should forward to carts show page and return back"
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
