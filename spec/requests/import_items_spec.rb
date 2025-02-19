require 'spec_helper'

# SYC extension to test file uploads
#include ActionDispatch::TestProcess

describe "Import items from" do
  
  let(:seller)   { FactoryGirl.create(:user) }
  let(:user)     { FactoryGirl.create(:user) }
  let(:event)    { FactoryGirl.create(:active) }
  let(:list)     { FactoryGirl.create(:assigned, user: seller, event: event) }
  let(:accepted) { FactoryGirl.create(:accepted, user: seller, event: event) }
  let(:file)     { Rack::Test::UploadedFile
                     .new(Rails.root.join('spec/fixtures/files/list-005.csv'), 
                          'text/csv') }

  describe "CSV" do

    describe "with no signed in user" do

      it "should not allow to select file to upload" do
        visit list_select_file_path(locale: :en, list_id: list.id)
        expect(page.current_path).to eq root_path(locale: :en)
        expect(page).to have_text "The requested operation is not available!"
      end

    end

    describe "by user not owning the list" do
      before { sign_in user }

      it "should not allow to select file to upload" do
        visit list_select_file_path(locale: :en, list_id: list.id)
        expect(page.current_path).to eq root_path(locale: :en)
        expect(page).to have_text "The requested operation is not available!"
      end

      it "should not allow to select items to import" do
        post list_select_items_path(locale: :en, list_id: list.id, file: file)
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
      before { sign_in seller }

      describe "with not accepted list" do
        before { visit list_select_file_path(locale: :en, list_id: list.id) }

        it "should have title 'Select Import File'" do
          expect(page).to have_title "Select Import File"
        end

        it "should have button 'Browse'" do
          expect(page).to have_selector("input", id: "file")
        end

        it "should have button 'Upload'" do
          expect(page).to have_button "Upload"
        end

        it "should show select items page" do
           page.attach_file("file", "spec/fixtures/files/list-005.csv")
           click_button "Upload"
           expect(page).to have_title "Select Items"
           expect(page).to have_text "Item"
           expect(page).to have_text "Description"
           expect(page).to have_text "Size"
           expect(page).to have_text "Price"

           check("selection_1")
           check("selection_4")
           expect { click_button "Import" }.to change(Item, :count).by(2)
        end
      end

      describe "with accepted list" do

        it "should not allow to select file to upload" do
          visit list_select_file_path(locale: :en, list_id: accepted.id)
          expect(page.current_path).to eq user_path(locale: :en, id: seller)
          text = "Cannot add items to accepted list #{accepted.list_number}"
          expect(page).to have_text text
        end

        it "should not allow to select items to import" do
          post list_select_items_path(locale: :en, list_id: accepted.id, 
                                      file: file)
          expect(response).to redirect_to user_path(locale: :en, id: seller.id)
          follow_redirect!
          text = "Cannot add items to accepted list #{accepted.list_number}"
          expect(response.body).to include text
        end

        it "should not allow to import items to list" do
          post list_import_items_path(locale: :en, list_id: accepted.id,
                                     selection: { "1" => { description: "D",
                                                           size:        "S",
                                                           price:       "2" } })
          expect(response).to redirect_to user_path(locale: :en, id: seller.id)
          follow_redirect!
          text = "Cannot add items to accepted list #{accepted.list_number}"
          expect(response.body).to include text
        end
      end
    end
  end

end
