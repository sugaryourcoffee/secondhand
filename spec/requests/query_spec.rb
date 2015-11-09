require 'spec_helper'

describe "Query" do

  let(:user)  { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:event) { FactoryGirl.create(:active) }
  let(:list)  { FactoryGirl.create(:list, user: user, event: event) }

  before do
    list.items.create!(item_attributes(item_number: 1, description: "One"))
    list.items.create!(item_attributes(item_number: 2, description: "Two"))
    list.items.create!(item_attributes(item_number: 3, description: "Three"))
    list.items.create!(item_attributes(item_number: 3, description: "One Word"))
  end

  describe "string" do

    describe "as admin user" do
      before do
        sign_in admin
        visit query_index_path(locale: :en)
      end

      it "should show all items containing the string" do
        fill_in "keywords", with: "One"
        click_button "Search"
        page.should have_text "One"
        page.should have_text "One Word"
      end
    end

    describe "as regular user" do
      before do
        sign_in user
        visit query_index_path(locale: :en)
      end

      it "should return to root path" do
        page.current_path.should eq root_path(locale: :en)
      end
    end

  end
  
end

