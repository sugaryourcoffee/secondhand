require 'spec_helper'

describe "Without active event" do

  let(:event)  { FactoryGirl.create(:event) }
  let!(:list)  { FactoryGirl.create(:list, event: event) }
  let(:admin)  { FactoryGirl.create(:admin) }

  context "in list pages" do
   
    before do
      sign_in admin
      visit lists_path(locale: :en)
    end

    it "should indicate no active event" do
      expect(page).to have_text "No active event"
      expect(page).to have_text list.registration_code
    end

  end
end
