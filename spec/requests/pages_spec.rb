require 'spec_helper'

describe "Pages" do

  let(:conditions)   { Conditions.create!(version: "08/2015", active: true) }
  let(:terms_of_use) { conditions.terms_of_uses.create!(locale: "en") }
  let(:admin)        { FactoryGirl.create(:admin) }
  let(:user)         { FactoryGirl.create(:user) }

  describe "by admin user" do

    before do
      create_pages_for_terms_of_use(terms_of_use, 1)
      sign_in admin
      visit terms_of_use_path(locale: :en, id: terms_of_use)
    end

    it "should add a new page" do
      click_link "Add new page"
      fill_in "Number", with: "2"
      fill_in "Title", with: "Title"
      fill_in "Content", with: "Content"

      expect { click_button "Create" }.to change(Page, :count).by(1)
    end

    it "should edit a page" do
      click_link "Edit"
      fill_in "Title", with: "Page number 99"
      fill_in "Content", with: "Content with 99 pages"
      click_button "Update"
      page.current_path.should eq terms_of_use_path(locale: :en, 
                                                    id: terms_of_use)
      page.should have_content "Page number 99"
      page.should have_content "Content with 99 pages"
    end

    it "should delete a page" do
      expect { click_link "Delete" }.to change(Page, :count).by(-1)
      page.current_path.should eq terms_of_use_path(locale: :en,
                                                    id: terms_of_use)
    end

    it "should move a page up" do
      click_link "Up"
    end

    it "should move a page down" do
      click_link "Down"
    end

  end

  describe "by regular user" do

    before do
      sign_in user
      visit terms_of_use_path(locale: :en, id: terms_of_use)
    end

    it "should not access terms of use page" do
      page.current_path.should eq root_path(locale: :en)
    end

  end

  describe "by no logged in user" do

    before { visit terms_of_use_path(locale: :en, id: terms_of_use) }

    it "should not access terms of use page" do
      page.current_path.should eq signin_path(locale: :en)
    end

  end

end
