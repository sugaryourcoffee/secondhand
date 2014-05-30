require 'spec_helper'

describe "Reversal cart pages" do
  include ItemsHelper

  let(:admin)   { FactoryGirl.create(:admin) }
  let(:seller)  { FactoryGirl.create(:user) }
  let(:event)   { FactoryGirl.create(:active) }
  let(:list1)   { FactoryGirl.create(:accepted, user: seller, event: event) }
  let(:list2)   { FactoryGirl.create(:accepted, user: seller, event: event) }
  let(:selling) { create_selling_and_items(event, list1) }

  before do
    sign_in admin
    visit line_item_collection_carts_path(locale: :en)
  end

  it "should have title Reversal" do
    page.should have_title 'Reversal'
  end

  it "should have selector Reversal" do
    page.should have_selector 'Reversal'
  end

  describe "with no active event" do

    it "should have warning about no active event"

    it "should forward to events page to activate event"

  end

  describe "with active event" do

    describe "line item collection" do

      it "should add line items" do
        fill_in 'List', with: list1.list_number
        fill_in 'Item', with: list1.items.first.item_number
        click_button 'Add'

        page.current_path.should eq line_item_collection_carts_path(locale: :en) 

        page.should have_text list_item_number_for(list1.items.first)
        page.should have_text list1.items.first.description
        page.should have_text list1.items.first.size
        page.should have_text list1.items.first.price
        page.should have_link 'Delete'
      end

      it "should have reversal statistics"

      it "should delete line items"

      it "should forward to reversal check out"
    end

    describe "reversal cart index page" do
      it "should show reversals"

      it "should show reversals statistics"

      it "should not delete reversal with line items"

      it "should delete reversal without line items"

      it "should forward to reversal show page"

      it "should print reversal"
    end

    describe "reversal cart show page" do
      it "should show reversal's line items"

      it "should show reversal statistics"

      it "should not delete a line item"

      it "should forward to reversal index page"
    end

  end

end
