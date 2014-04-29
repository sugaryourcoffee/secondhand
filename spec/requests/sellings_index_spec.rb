require 'spec_helper'

describe "Selling index page" do

  let(:admin)             { FactoryGirl.create(:admin) }
  let(:seller)            { FactoryGirl.create(:user) }
  let!(:accepted_list)    { FactoryGirl.create(:accepted, user: seller, event: event) }

  context "with no active event" do
    let(:event) { FactoryGirl.create(:event) }

    before do
      sign_in(admin)
      visit sellings_path(locale: :en)
    end

    it "should have title Selling" do
      page.should have_title 'Selling'   
    end

    it "should have selector Selling" do
      page.should have_text 'Selling'
    end

    it "should have warning about no active event" do
      page.should have_text "For selling it is neccessary to have an active event"
      page.should have_link "activate_event"
      click_link "activate_event"
      current_path.should eq events_path(locale: :en)
    end
  end

  context "with active event" do

    let!(:event) { FactoryGirl.create(:active) }

    before do
      sign_in(admin)
      visit sellings_path(locale: :en)
    end
 
    it "should create new selling"

    it "should list available sellings"

    it "should forward to edit selling page when searching for existing selling"

    it "should show edit selling page when pressing the edit link on a selling"

    it "should delete a selling and mark containing items as not sold"

    it "should show statistics of the sellings"

    it "should have a print button at each selling"

  end

end

