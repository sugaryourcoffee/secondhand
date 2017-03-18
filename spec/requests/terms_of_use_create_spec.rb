require 'spec_helper'

describe "Create terms of use" do

  let(:admin)         { FactoryGirl.create(:admin) }
  let(:user)          { FactoryGirl.create(:user)  }
  let(:conditions)    { Conditions.create!(version: "01/2016") }
  let!(:terms_of_use) { conditions.terms_of_uses.create!(locale: "en") }

  describe "by admin user" do
    before do
      sign_in admin
      visit conditions_path(locale: :en)
    end

    it "should activate terms of use" do
      conditions.active.should be_falsey
      click_link "Activate"
      conditions.reload.active.should be_truthy
      click_link "Deactivate"
      conditions.reload.active.should be_falsey
    end

    it "should create new terms of use and forward to terms of use show page" do
      page.current_path.should eq conditions_path(locale: :en)
      click_link "Create new Terms of Sales"
      fill_in "Version", with: "2015/01"
      expect { click_button "Create" }.to change(Conditions, :count).by(1)
      page.current_path.should eq condition_path(locale: :en, 
                                                  id: Conditions.last)
      page.should have_text Conditions.last.version
      Conditions.last.active.should be_falsey
    end

    it "should edit terms of use version" do
      click_link "Edit"
      fill_in "Version", with: "2015/02"
      click_button "Update"
      conditions.reload.version.should eq "2015/02"
    end

    it "should copy terms of use version with associated locales and pages" do
      conditions_count = Conditions.all.count
      click_link "Copy"
      fill_in "Version", with: "2016/01"
      click_button "Update"
      page.current_path.should eq condition_path(locale: :en, 
                                                 id: Conditions.last)
      Conditions.last.version.should eq "2016/01"
      Conditions.all.count.should eq conditions_count + 1
    end

    it "should delete terms of use version with associated locales and pages" do
      expect { click_link "Delete" }.to change(Conditions, :count).by(-1)
    end
 
    it "should create new locale for terms of use" do
      visit condition_path(locale: :en, id: conditions)
      click_link "Create new Language Version"
      select "Deutsch", from: "Locale"
      expect { click_button "Create" }.to change(TermsOfUse, :count).by(1)
      page.current_path.should eq terms_of_use_path(locale: :en, 
                                                    id: TermsOfUse.last)
      page.should have_text TermsOfUse.last.locale
    end

    it "should create a page for terms of use" do
      conditions.terms_of_uses.first.should eq terms_of_use
      visit condition_path(locale: :en, id: conditions)
      click_link "Show"
      page.current_path.should eq terms_of_use_path(locale: :en,
                                                    id: terms_of_use)
      click_link "Add new page"
      fill_in "Title", with: "My first page"
      fill_in "Content", with: "Content of my first page"
      expect { click_button "Create" }.to change(Page, :count).by(1)
      page.current_path.should eq terms_of_use_path(locale: :en,
                                                    id: terms_of_use)
    end

    it "should edit locale of terms of use" do
      visit condition_path(locale: :en, id: conditions)
      click_link "Edit"
      select "Deutsch", from: "Locale"
      click_button "Update"
      page.current_path.should eq terms_of_use_path(locale: :en, 
                                                    id: terms_of_use)
    end

    it "should copy locale for terms of use" do
      locale_count = conditions.terms_of_uses.count
      visit condition_path(locale: :en, id: conditions)
      click_link "Copy"
      page.current_path.should eq edit_terms_of_use_path(locale: :en,
                                                         id: TermsOfUse.last)
      select "Deutsch", from: "Locale"
      click_button "Update"
      page.current_path.should eq terms_of_use_path(locale: :en, 
                                                    id: TermsOfUse.last)
      conditions.terms_of_uses.count.should eq locale_count + 1
    end

    it "should delete locale from terms of use" do
      visit condition_path(locale: :en, id: conditions)
      expect { click_link "Delete" }.to change(TermsOfUse, :count).by(-1) 
    end

  end

  describe "by non-admin user" do

    before do
      sign_in user
    end

    it "should not access conditions page" do
      visit conditions_path(locale: :en)
      page.current_path.should eq root_path(locale: :en)
    end

    it "should not access condition page" do
      visit condition_path(locale: :en, id: conditions)
      page.current_path.should eq root_path(locale: :en)
    end
 
  end

  describe "by no user logged in" do

    it "should not access conditions page" do
      visit conditions_path(locale: :en)
      page.current_path.should eq signin_path(locale: :en)
    end

    it "should not access condition page" do
      visit condition_path(locale: :en, id: conditions)
      page.current_path.should eq signin_path(locale: :en)
    end
 
  end

end
