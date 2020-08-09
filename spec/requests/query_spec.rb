require 'spec_helper'

describe "Query" do

  let(:user)  { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:event) { FactoryGirl.create(:active) }
  let(:list)  { FactoryGirl.create(:list, user: user, event: event) }

  context "with active event" do
    before do
      list.items.create!(item_attributes(item_number: 1, description: "One"))
      list.items.create!(item_attributes(item_number: 2, description: "Two"))
      list.items.create!(item_attributes(item_number: 3, description: "Three"))
      list.items.create!(item_attributes(item_number: 3, 
                                         description: "One Word"))
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
          expect(page).to have_text "One"
          expect(page).to have_text "One Word"
        end
      end

      describe "as regular user" do
        before do
          sign_in user
          visit query_index_path(locale: :en)
        end

        it "should return to root path" do
          expect(page.current_path).to eq root_path(locale: :en)
        end
      end

    end
  end
  
  context "with no active event" do

    before do
      sign_in admin
      event.toggle!(:active)
      visit query_index_path(locale: :en)
    end

    it "should indicate no active event" do
      expect(page).to have_text "Missing active Event"
    end

  end

end

