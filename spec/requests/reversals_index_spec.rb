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
    expect(page).to have_title 'Redemptions'
  end

  it "should have heading Reversals" do
    expect(page).to have_selector('h1', text: 'Redemptions')
  end

  describe "with no active event" do
    let(:event)     { FactoryGirl.create(:event) }

    it "should show a warning about no active event" do
      expect(page).to have_text 'Missing active Event'
    end

    it "should forward to events page to activate an event" do
      expect(page).to have_link 'Events'
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
      expect(page).to have_text 'Redemption Status'
      expect(page).to have_text 'Redemptions'
      expect(page).to have_text '2'
      expect(page).to have_text 'Items'
      expect(page).to have_text '3'
      expect(page).to have_text 'Total'
      expect(page).to have_text total.to_s
    end

    it "should show available reversals" do
      expect(page).to have_text 'Number'
      expect(page).to have_text 'Items'
      expect(page).to have_text 'Redemption'
      expect(page).to have_text reversal1.id
      expect(page).to have_text reversal1.line_items.count
      expect(page).to have_text reversal1.total
      expect(page).to have_link "show_reversal_#{reversal1.id}"
      expect(page).to have_link "print_reversal_#{reversal1.id}"
      expect(page).to have_text reversal2.id
      expect(page).to have_text reversal2.line_items.count
      expect(page).to have_text reversal2.total
      expect(page).to have_link "show_reversal_#{reversal2.id}"
      expect(page).to have_link "print_reversal_#{reversal2.id}"
    end

    it "should forward to reversal show page" do
      click_link "show_reversal_#{reversal1.id}"
      expect(page.current_path).to eq reversal_path(locale: :en, id: reversal1.id)
    end

    it "should forward to reversal show page through find" do
      fill_in 'Redemption', with: reversal1.id
      click_button "Search"
      expect(page.current_path).to eq reversal_path(locale: :en, id: reversal1.id)
    end

    it "should print a reversal" do
      click_link "print_reversal_#{reversal2.id}"
      expect(page).to have_text "Printed redemption #{reversal2.id}"
    end

    it "should not delete a reversal with items", :js => true do
      click_link "delete_reversal_#{reversal1.id}"
      modal = page.driver.browser.switch_to.alert
      modal.accept

      expect(page.current_path).to eq reversals_path(locale: :en)

      expect(page).to have_text reversal1.id
      expect(page).to have_text reversal1.total

      expect(page).to have_text "Cannot delete redemption when containing items"
    end
  end

end

