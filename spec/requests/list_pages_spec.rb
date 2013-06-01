require 'spec_helper'

describe List do

  subject { page }

  describe "item collection" do

    let(:user) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:assigned, user: user) }

    before do
      sign_in user
      visit user_list_items_path(user, list)
    end

    it { should have_text("Collect Items") }
    it { should have_link("Create New Item", 
                          href: new_user_list_item_path(user, list)) }

    it "should create item" do
      click_link "Create New Item"
      fill_in "Description", with: "This is my first item"
      fill_in "Size", with: "XXXS"
      fill_in "Price", with: 1.5

      expect { click_button("Create Item") }.to change(Item, :count).by(1)
    end

    it "should delete item" do
      pending "needs to be implemented"
    end

    it "should show item" do
      pending "needs to be implemented"
    end

  end

end
