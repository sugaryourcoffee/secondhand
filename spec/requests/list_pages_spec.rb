require 'spec_helper'

describe List do

  subject { page }

  describe "item collection" do

    let(:event) { FactoryGirl.create(:active) }
    let(:user) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:assigned, user: user, event: event) }

    before do
      sign_in user
      visit user_list_items_path(user, list, locale: :en)
    end

    it { should have_text("Collect Items") }
    it { should have_link("Create New Item", 
                          href: new_user_list_item_path(user, list, locale: :en)) }

    it "should create item" do
      click_link "Create New Item"
      fill_in "Description", with: "This is my first item"
      fill_in "Size", with: "XXXS"
      fill_in "Price", with: 1.5

      expect { click_button("Create Item") }.to change(Item, :count).by(1)

      should have_text("This is my first item")

      should have_link("Show")
      should have_link("Edit")
      should have_link("Destroy")

    end

    it "should not create more than max items" do
      1.upto(event.max_items_per_list) do |i|
        click_link "Create New Item"
        fill_in "Description", with: "This is my #{i}. item"
        fill_in "Size", with: "#{i}"
        fill_in "Price", with: i
        expect { click_button("Create Item") }.to change(Item, :count).by(1)
      end 

      should_not have_link "Create New Item"
      should have_text "Cannot add additional items"
    end

    it "should not allow editing list when list has accepted status"

  end

  describe "process items" do

    let(:user) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:assigned, user: user) }

    before do
      sign_in user

      visit user_list_items_path(user, list, locale: :en)

      click_link "Create New Item"

      fill_in "Description", with: "This is my item"
      fill_in "Size", with: "XS"
      fill_in "Price", with: 2.5

      click_button "Create Item"
    end

    it "should show item" do
      click_link "Show"

      should have_selector('h1', text: "Show Item")
      should have_text("Description: This is my item")
    end

    it "should edit item" do
      click_link "Edit"

      should have_selector('h1', text: "Edit Item")

      fill_in "Description", with: "This is my changed item"
      
      click_button "Update Item"

      should have_selector('h1', text: "Collect Items")
      should have_text("This is my changed item")
    end

    it "should destroy item" do
      expect { click_link("Destroy") }.to change(Item, :count).by(-1)
    end

  end

end
