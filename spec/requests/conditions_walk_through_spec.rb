require 'spec_helper'

describe "Conditions" do

  let(:admin)         { FactoryGirl.create(:admin) }
  let(:user)          { FactoryGirl.create(:user)  }
 
  before { sign_in admin }

  it "should walk through" do
    visit conditions_path(locale: :en)
    click_link "Create new Terms of Use"
    fill_in "Version", with: "01/2016"
    click_button "Create"
    click_link "Create new Language Version"
    select "English", from: "Locale"
    click_button "Create"
    click_link "Add new page"
    fill_in "Title", with: "First page"
    fill_in "Content", with: "Content of first page"
    click_button "Create"
    click_link "Add new page"
    fill_in "Title", with: "Second page"
    fill_in "Content", with: "Content of second page"
    click_button "Create"
    click_link "01/2016"

    Conditions.all.size.should eq 1

    Conditions.last.terms_of_uses.size.should eq 1
    Conditions.last.terms_of_uses.first.pages.size.should eq 2

    click_link "Copy"
    select "Deutsch", from: "Locale"
    click_button "Update"

    Conditions.all.size.should eq 1

    Conditions.last.terms_of_uses.size.should eq 2
    Conditions.last.terms_of_uses.first.pages.size.should eq 2
    Conditions.last.terms_of_uses.last.pages.size.should eq 2

    visit conditions_path(locale: :en)
    click_link "Copy"
    fill_in "Version", with: "02/2016"
    click_button "Update"

    Conditions.all.size.should eq 2

    Conditions.first.terms_of_uses.size.should eq 2
    Conditions.first.terms_of_uses.first.pages.size.should eq 2
    Conditions.first.terms_of_uses.last.pages.size.should eq 2

    Conditions.last.terms_of_uses.size.should eq 2
    Conditions.last.terms_of_uses.first.pages.size.should eq 2
    Conditions.last.terms_of_uses.last.pages.size.should eq 2
  end
end
