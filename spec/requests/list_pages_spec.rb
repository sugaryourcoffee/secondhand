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

    it { is_expected.to have_text("Collect Items") }
    it { is_expected.to have_link("Create New Item", 
                       href: new_user_list_item_path(user, list, locale: :en)) }

    it "should create item" do
      click_link "Create New Item"
      fill_in "Description", with: "This is my first item"
      fill_in "Size", with: "XXXS"
      fill_in "Price", with: 1.5

      expect { click_button("Create Item") }.to change(Item, :count).by(1)

      is_expected.to have_text("This is my first item")

      is_expected.to have_link("Show")
      is_expected.to have_link("Edit")
      is_expected.to have_link("Destroy")

    end

    it "should not create more than max items" do
      1.upto(event.max_items_per_list) do |i|
        click_link "Create New Item"
        fill_in "Description", with: "This is my #{i}. item"
        fill_in "Size", with: "#{i}"
        fill_in "Price", with: i
        expect { click_button("Create Item") }.to change(Item, :count).by(1)
      end 

      is_expected.not_to have_link "Create New Item"
      is_expected.to have_text "Cannot add additional items"
    end

    it "should not create item when list has accepted status" do
      click_link "Create New Item"
      fill_in "Description", with: "First Item"
      fill_in "Size", with: "XXL"
      fill_in "Price", with: 10
      expect { click_button("Create Item") }.to change(Item, :count).by(1)

      list.accepted_on = Time.now
      list.save!

      click_link "Create New Item"
      expect(current_path).to eq user_path(locale: :en, id: user)
      is_expected.to have_text "Cannot create item for accepted list number #{list.list_number}"
    end

  end

  describe "process items" do

    let(:event) { FactoryGirl.create(:active) }
    let(:user) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:assigned, user: user, event: event) }

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

      is_expected.to have_selector('h1', text: "Show Item")
      is_expected.to have_text("Description: This is my item")
    end

    it "should edit item" do
      click_link "Edit"

      is_expected.to have_selector('h1', text: "Edit Item")

      fill_in "Description", with: "This is my changed item"
      
      click_button "Update Item"

      is_expected.to have_selector('h1', text: "Collect Items")
      is_expected.to have_text("This is my changed item")
    end

    it "should not edit item of accepted list" do
      list.accepted_on = Time.now
      list.save!

      click_link "Edit"

      expect(current_path).to eq user_path(locale: :en, id: user)
      is_expected.to have_text "Cannot edit item of accepted list number #{list.list_number}"
    end

    it "should destroy item" do
      expect { click_link("Destroy") }.to change(Item, :count).by(-1)
    end

    it "should not destroy item of accepted list" do
      list.accepted_on = Time.now
      list.save!

      click_link "Destroy"

      expect(current_path).to eq user_path(locale: :en, id: user)
      is_expected.to have_text "Cannot delete item of accepted list number #{list.list_number}"
    end

  end

end
