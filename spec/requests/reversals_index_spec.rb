require 'spec_helper'

describe "Reversals index page" do

  let(:admin)     { FactoryGirl.create(:admin) }
  let(:seller)    { FactoryGirl.create(:user) }
  let(:list)      { FactoryGirl.create(:accepted, user: seller, event: event) }

  before do
    sign_in admin
    visit reversals_path(locale: :en)
  end

  it "should have title Reversals" do
    page.should have_title 'Redemptions'
  end

  it "should have heading Reversals" do
    page.should have_selector 'h1', 'Redemptions'
  end

  describe "with no active event" do
    let(:event)     { FactoryGirl.create(:event) }

    it "should show a warning about no active event" do
      page.should have_text 'Missing active Event'
    end

    it "should forward to events page to activate an event" do
      page.should have_link 'Events'
    end
  end

  describe "with active event" do
    let!(:event)     { FactoryGirl.create(:active) }
    let!(:selling)   { create_selling_and_items(event, list, 3) }
    let!(:reversal1) { create_reversal(event, selling, 0, 2) }
    let!(:reversal2) { create_reversal(event, selling, 2, 1) }

    before do
      sign_in admin
      visit reversals_path(locale: :en)
    end

    it "should show reversal statistics" do
      total = reversal1.total + reversal2.total
      page.should have_text 'Redemption Status'
      page.should have_text 'Redemptions'
      page.should have_text '2'
      page.should have_text 'Items'
      page.should have_text '3'
      page.should have_text 'Total'
      page.should have_text total.to_s
    end

    it "should show available reversals" do
      page.should have_text 'Number'
      page.should have_text 'Items'
      page.should have_text 'Redemption'
      page.should have_text reversal1.id
      page.should have_text reversal1.line_items.count
      page.should have_text reversal1.total
      page.should have_link "show_reversal_#{reversal1.id}"
      page.should have_link "print_reversal_#{reversal1.id}"
      page.should have_text reversal2.id
      page.should have_text reversal2.line_items.count
      page.should have_text reversal2.total
      page.should have_link "show_reversal_#{reversal2.id}"
      page.should have_link "print_reversal_#{reversal2.id}"
    end

    it "should forward to reversal show page" do
      click_link "show_reversal_#{reversal1.id}"
      page.current_path.should eq reversal_path(locale: :en, id: reversal1.id)
    end

    it "should forward to reversal show page through find" do
      fill_in 'Redemption', with: reversal1.id
      click_button "Search"
      page.current_path.should eq reversal_path(locale: :en, id: reversal1.id)
    end

    it "should print a reversal" do
      click_link "print_reversal_#{reversal2.id}"
      page.should have_text "Printed redemption #{reversal2.id}"
    end

  end

end

