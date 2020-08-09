require 'spec_helper'

describe "Submit terms of use" do

  let!(:user)       { FactoryGirl.create(:user) }
  let!(:event)      { FactoryGirl.create(:active) }
  let!(:conditions) { Conditions.create!(version: "01/2016", active: true) }

  describe "after user logs in" do

    describe "without accepted terms of use" do

      before { sign_in user }

      it "should forward to terms of use page" do
        expect(page.current_path).to eq display_terms_of_use_path(locale: :en)
        click_link "My Lists"
        expect(page.current_path).to eq display_terms_of_use_path(locale: :en)
      end

    end

    describe "with expired terms of use" do
      
      before do
        user.update(terms_of_use: event.created_at - 1)
        sign_in user
      end

      it "should forward to terms of use page" do
        expect(page.current_path).to eq display_terms_of_use_path(locale: :en)
      end

    end

    describe "with accepted terms of use" do

      before do
        user.update(terms_of_use: event.created_at + 1)
        sign_in user
      end

      it "should forward to user's page" do
        expect(page.current_path).to eq user_path(locale: :en, id: user)
      end

    end

  end

  describe "to logged in user" do
    
    before { sign_in user }

    describe "with no terms of use" do

      before { visit display_terms_of_use_path(locale: :en) }

      it { expect(page).to have_text "To obtain the Terms of Sales please turn to \
           your Secondhand organizer" }

    end

    describe "with no pages" do

      let(:condition) { Conditions.create!(active: true) }

      before { visit display_terms_of_use_path(locale: :en) }

      it { expect(page).to have_text "To obtain the Terms of Sales please turn to \
           your Secondhand organizer" }

    end

    describe "with no activated terms of use" do
      let(:condition) { Conditions.create!(active: false) }

      before { visit display_terms_of_use_path(locale: :en) }

      it { expect(page).to have_text "To obtain the Terms of Sales please turn to \
           your Secondhand organizer" }

    end

    describe "with one page" do

      before do
        create_pages_for(conditions, 1)
        sign_in user
      end

      it "should show page" do
        expect(page.current_path).to eq display_terms_of_use_path(locale: :en)
        pages = conditions.terms_of_uses.first.pages
        expect(page).to have_content pages.first.title
        expect(page).to have_content pages.first.content
        click_link "Accept"
        expect(page.current_path).to eq user_path(locale: :en, id: user)
        visit display_terms_of_use_path(locale: :en)
        expect(page).not_to have_button "Accept"
        click_link "Close"
        expect(page.current_path).to eq user_path(locale: :en, id: user)
      end

    end

    describe "with four pages" do
      
      before do
        create_pages_for(conditions, 4)
        sign_in user
      end

      it "should show all pages" do
        terms_of_use = conditions.terms_of_uses.first
        expect(page).to have_content terms_of_use.pages.first.title 
        expect(page).to have_content terms_of_use.pages.first.content 
        click_link "Next"
        expect(page).to have_content terms_of_use.pages.find_by(number: 2).title
        expect(page).to have_content terms_of_use.pages.find_by(number: 2).content
        click_link "Next"
        click_link "Next"
        click_link "Accept"
        expect(page.current_path).to eq user_path(locale: :en, id: user)
        visit display_terms_of_use_path(locale: :en)
        click_link "Next"
        click_link "Next"
        click_link "Next"
        expect(page).not_to have_button "Accept"
        click_link "Close"
        expect(page.current_path).to eq user_path(locale: :en, id: user)
      end

    end
  end

  describe "to not logged in user" do

    describe "with one page" do

      before do
        create_pages_for(conditions, 1)
      end

      it "should show page" do
        visit display_terms_of_use_path(locale: :en)
        pages = conditions.terms_of_uses.first.pages
        expect(page).to have_content pages.first.title
        expect(page).to have_content pages.first.content
        expect(page).not_to have_button "Accept"
        click_link "Close"
        expect(page.current_path).to eq root_path(locale: :en)
      end

    end

    describe "with four pages" do

      before do
        create_pages_for(conditions, 4)
      end

      it "should show all pages" do
        visit display_terms_of_use_path(locale: :en)
        terms_of_use = conditions.terms_of_uses.first
        expect(page).to have_content terms_of_use.pages.first.title 
        expect(page).to have_content terms_of_use.pages.first.content 
        click_link "Next"
        expect(page).to have_content terms_of_use.pages.find_by(number: 2).title
        expect(page).to have_content terms_of_use.pages.find_by(number: 2).content
        click_link "Next"
        click_link "Next"
        expect(page).not_to have_button "Accept"
        click_link "Close"
        expect(page.current_path).to eq root_path(locale: :en)
      end

    end

  end

end
