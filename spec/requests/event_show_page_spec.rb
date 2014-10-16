require 'spec_helper'

describe "event show page" do

  let(:event) { FactoryGirl.create(:active) }
  let(:user)  { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }

  describe "with no user signed in" do

    it "should not forward to show page" do
      visit event_path(event, locale: :en)

      current_path.should eq signin_path(locale: :en)
    end

  end

  describe "with non-admin user signed in" do

    it "should not forward to show page" do
      sign_in user

      visit event_path(event, locale: :en)
      current_path.should eq root_path(locale: :en)
    end

  end

  describe "with admin user signed in" do

    before do
      sign_in admin
      visit event_path(event, locale: :en)
     end

    it "should forward to show page" do
      current_path.should eq event_path(event, locale: :en)
    end

    it "should have a link to print pickup tickets" do
      page.should have_link('Print Pickup Tickets',
                      href: print_pickup_tickets_event_path(event, locale: :en))
    end

    it "should have a link to print lists" do
      page.should have_link('Print Lists', 
                            href: print_lists_event_path(event, locale: :en))
    end

  end

end

