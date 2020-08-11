require 'spec_helper'

describe 'Statistic pages' do

  let(:admin) { FactoryGirl.create(:admin) }
  let(:base_title) { "Secondhand" }

  before { sign_in admin }
  before { visit statistics_overview_path(locale: :en) }

  it "should have title 'Statistics'" do
    expect(page).to have_title("#{base_title} | Statistics")
  end

  it "should have statistics headings" do
    expect(page).to have_selector("h1", text: "Statistics")
    expect(page).to have_selector("h2", text: "General Information")
    expect(page).to have_selector("h2", text: "Sellings")
    expect(page).to have_selector("h2", text: "Reversals")
  end

end
