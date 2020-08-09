require 'spec_helper'

describe "Import lists" do

  let(:seller)    { FactoryGirl.create(:user) }
  let(:user)      { FactoryGirl.create(:user) }
  let(:event)     { FactoryGirl.create(:active) }
  let(:list)      { FactoryGirl.create(:assigned, user: seller, event: event) }
  let(:accepted)  { FactoryGirl.create(:accepted, user: seller, event: event) }
  let(:old_event) { FactoryGirl.create(:event) }
  let(:list1)     { FactoryGirl.create(:assigned, user: seller, 
                                       event: old_event) }
  let(:list2)     { FactoryGirl.create(:assigned, user: seller, 
                                       event: old_event) }
  let(:list3)     { FactoryGirl.create(:assigned, user: user,
                                       event: old_event) }
 
  before do
    list1.items.create!(item_attributes)
    list2.items.create!(item_attributes)
  end

  describe "by not signed in user" do

    it "should not redirect to root path" do
      visit list_select_lists_path(locale: :en, list_id: list.id)
      expect(page.current_path).to eq root_path(locale: :en)
      expect(page).to have_text "The requested operation is not available!"
    end

  end

  describe "by user not owning list" do

    before { sign_in user }

    it "should not allow to select lists to import" do
      visit list_select_lists_path(locale: :en, list_id: list.id)
      expect(page.current_path).to eq root_path(locale: :en)
      expect(page).to have_text "The requested operation is not available!"
    end

    it "should not allow to select items to import" do
      post list_select_items_path(locale: :en, list_id: list.id, 
                                  lists: [list1.id, list2.id])
      expect(response).to redirect_to root_path(locale: :en)
      follow_redirect!
      response_body = "The requested operation is not available!" 
      expect(response.body).to include response_body
    end

    it "should not allow to import items to list" do
      post list_import_items_path(locale: :en, list_id: list.id,
                                  selection: { "1" => { description: "D",
                                                        size:        "S",
                                                        price:       "2" } })
      expect(response).to redirect_to root_path(locale: :en)
      follow_redirect!
      response_body = "The requested operation is not available!" 
      expect(response.body).to include response_body
    end

  end

  describe "by list owner" do
    
    before do
      sign_in seller
      visit list_select_lists_path(locale: :en, list_id: list.id)
    end

    it "should have title 'Import items from lists'" do
      expect(page).to have_title("Select Import Lists")
    end

    it "should have drop down list with all user's old lists" do
      date = "#{old_event.event_date.month}/#{old_event.event_date.year}"
      expect(page).to have_text "#{old_event.title} (#{date}) - List #{list1.list_number}"
      expect(page).to have_text "#{old_event.title} (#{date}) - List #{list2.list_number}"
    end

    it "should not have lists from active event in drop down list" do
      date = "#{event.event_date.month}/#{event.event_date.year}"
      expect(page).not_to have_link "#{event.title} (#{date}) - List #{list.list_number}"
    end

    it "should import items from old list" do
      date = "#{old_event.event_date.month}/#{old_event.event_date.year}"
      select "#{old_event.title} (#{date}) - List #{list1.list_number}"
      click_button "Select"
      expect(page.current_path).to eq list_select_items_path(locale: :en, 
                                                         list_id: list.id)
      expect(page).to have_title "Select Items"
      expect(page).to have_text "Item"
      expect(page).to have_text "Description"
      expect(page).to have_text "Size"
      expect(page).to have_text "Price"

      check("selection_1")
      expect { click_button "Import" }.to change(Item, :count).by(1)
    end

  end

end
