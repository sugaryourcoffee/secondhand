require 'spec_helper'

describe TermsOfUse do

  let(:user)  { FactoryGirl.create(:user) }
  let(:event) { FactoryGirl.create(:active) }

  describe "logged in user" do
    
    before { sign_in user }

    describe "with no terms of use" do

      before { visit terms_of_use_path(locale: :en) }

      it { page.should have_text "To obtain the Terms of Use please turn to \
           your Secondhand organizer" }

    end

    describe "with no pages" do

      let(:terms_of_use) { TermsOfUse.create!(active: true) }

      before { visit terms_of_use_path(locale: :en) }

      it { page.should have_text "To obtain the Terms of Use please turn to \
           your Secondhand organizer" }

    end

    describe "with one page" do

      let(:terms_of_use) { TermsOfUse.create!(active: true) }

      before do
        create_pages_for(terms_of_use, 1)
      end

      it "should show page" do
        visit terms_of_use_path(locale: :en)
        page.should have_content terms_of_use.pages.first.title 
        page.should have_content terms_of_use.pages.first.content 
        click_link "Accept"
        page.current_path.should eq user_path(locale: :en, id: user)
        visit terms_of_use_path(locale: :en)
        page.should_not have_button "Accept"
        click_link "Close"
        page.current_path.should eq user_path(locale: :en, id: user)
      end

    end

    describe "with four pages" do
      
      let(:terms_of_use) { TermsOfUse.create!(active: true) }

      before do
        create_pages_for(terms_of_use, 4)
      end

      it "should show all pages" do
        visit terms_of_use_path(locale: :en)
        page.should have_content terms_of_use.pages.first.title 
        page.should have_content terms_of_use.pages.first.content 
        click_link "Next"
        page.should have_content terms_of_use.pages.find_by(number: 2).title
        page.should have_content terms_of_use.pages.find_by(number: 2).content
        click_link "Next"
        click_link "Next"
        click_link "Accept"
        page.current_path.should eq user_path(locale: :en, id: user)
        visit terms_of_use_path(locale: :en)
        click_link "Next"
        click_link "Next"
        click_link "Next"
        page.should_not have_button "Accept"
        click_link "Close"
        page.current_path.should eq user_path(locale: :en, id: user)
      end

    end
  end

end
