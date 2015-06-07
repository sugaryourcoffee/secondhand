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
    end

    describe "Statistics section" do
    end

    describe "Sellings section" do
    end

    describe "Reversals section" do
    end
  end

end
