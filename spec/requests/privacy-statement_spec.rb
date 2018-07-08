require 'spec_helper'

describe "Privacy Statement" do

  before { visit root_path(locale: :en) }

  it "has a privacy statement text in the footer" do
    expect(page).to have_text "Privacy Statement"
  end

  it "has a privacy statement link in the footer" do
    expect(page).to have_link "Privacy Statement"
  end

  it "opens the privacy statement pdf when I click on the link" do
    click_link "Privacy Statement"
    expect(current_path).to eq "/en/privacy_statement"
  end
 
end


