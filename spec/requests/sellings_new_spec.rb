require 'spec_helper'

describe "New selling" do

  let(:event)         { FactoryGirl.create(:active) }
  let(:admin)         { FactoryGirl.create(:admin) }
  let(:seller)        { FactoryGirl.create(:user) }
  let(:accepted_list) { FactoryGirl.create(:accepted, user: seller, event: event) }
  
  before do
    sign_in admin
    visit new_selling_path(locale: :en)
  end

  it "should have title New Selling" do
    page.should have_title('New Selling') 
  end

  it "should have heading New Selling" do
    page.should have_selector('h1', 'New Selling')
  end

  it "should have statistics about the selling" do
    page.should have_text('Selling Status')
    page.should have_text('Items')
    page.should have_text('Total')
    page.should have_text('Last added item')
    page.should have_text('Selling contains no items yet')
  end

  it "should cancel selling" do
    click_link 'Cancel'

    page.current_path.should eq sellings_path(locale: :en)
  end

  context "adding items" do

    before do
      add_items_to_list(accepted_list, 5)
    end

    it "should not create selling without items" do
      page.should have_text "Finish selling"
      page.should_not have_button "Finish selling"
      page.should have_text "Finish and start next selling"
      page.should_not have_button "Finish and start next selling"
    end

    it "should add item to selling" do
      list_number = accepted_list.list_number
      items       = accepted_list.items

      fill_in 'List', with: list_number
      fill_in 'Item', with: items.first.item_number
      click_button 'Add'
 
      page.current_path.should eq new_selling_path(locale: :en)

      page.should have_text "#{list_number}/#{items.first.item_number}"
      page.should have_text items.first.description
      page.should have_text items.first.size
      page.should have_text items.first.price
      page.should have_link 'Delete'
    end

    it "should create selling and return to sellings index page" do
      list_number = accepted_list.list_number
      items       = accepted_list.items

      fill_in 'List', with: list_number
      fill_in 'Item', with: items.first.item_number
      click_button 'Add'
 
      expect { click_button 'Finish selling' }.to change(class: Selling).by(1)

      page.current_path.should eq sellings_path(locale: :en)
    end

    it "should create selling and open new selling page" do
      list_number = accepted_list.list_number
      items       = accepted_list.items

      fill_in 'List', with: list_number
      fill_in 'Item', with: items.first.item_number
      click_button 'Add'
 
      expect { click_button 'Finish and start next selling' }.to change(class: Selling).by(1)

      page.current_path.should eq edit_selling_path(locale: :en)

      page.should_not have_text "#{list_number}/#{items.first.item_number}"
      page.should_not have_text items.first.description
      page.should_not have_text items.first.size
      page.should_not have_text items.first.price
      page.should_not have_link 'Delete'
    end

    it "should not add already sold item"

    it "should not add locked item"

    it "should remove item and unlock it"

  end

end
