require 'spec_helper'

describe "Conditions" do

  let(:admin)         { FactoryGirl.create(:admin) }
  let(:user)          { FactoryGirl.create(:user)  }
 
  before { sign_in admin }

  it "should walk through" do
    visit conditions_path(locale: :en)
    click_link "Create new Terms of Sales"
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

    expect(Conditions.all.size).to eq 1

    expect(Conditions.last.terms_of_uses.size).to eq 1
    expect(Conditions.last.terms_of_uses.first.pages.size).to eq 2

    click_link "Copy"
    select "Deutsch", from: "Locale"
    click_button "Update"

    expect(Conditions.all.size).to eq 1

    expect(Conditions.last.terms_of_uses.size).to eq 2
    expect(Conditions.last.terms_of_uses.first.pages.size).to eq 2
    expect(Conditions.last.terms_of_uses.last.pages.size).to eq 2

    click_link "Terms of Sales Overview"
    click_link "Copy"
    fill_in "Version", with: "02/2016"
    click_button "Update"

    expect(Conditions.all.size).to eq 2

    expect(Conditions.first.terms_of_uses.size).to eq 2
    expect(Conditions.first.terms_of_uses.first.pages.size).to eq 2
    expect(Conditions.first.terms_of_uses.last.pages.size).to eq 2

    expect(Conditions.last.terms_of_uses.size).to eq 2
    expect(Conditions.last.terms_of_uses.first.pages.size).to eq 2
    expect(Conditions.last.terms_of_uses.last.pages.size).to eq 2
  end
end
