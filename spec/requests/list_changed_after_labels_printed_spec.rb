require 'spec_helper'

describe "List change" do

  let(:active) { FactoryGirl.create(:active) }
  let(:user)   { FactoryGirl.create(:user) }
  let(:admin)  { FactoryGirl.create(:admin) }
  let(:list)   { FactoryGirl.create(:assigned, user: user, event: active) }

  before do
    list.items.create(item_attributes)
    sign_in admin
  end

  context "before labels printed" do
    it "should not indicate item changed" do
      visit user_path(locale: :en, id: user)
      click_link "Labels"
      visit edit_acceptance_path(locale: :en, id: list)
      expect(page).not_to have_text ">>>"
    end
  end

  context "before list sent" do
    it "should not indicate item changed" do
      list.update(sent_on: Time.now)
      visit edit_acceptance_path(locale: :en, id: list)
      expect(page).not_to have_text ">>>"
    end
  end

  context "after labels printed" do
    it "should indicate item changed" do
      visit user_path(locale: :en, id: user)
      click_link "Labels"
      list.items.first.update(price: 1000)
      visit edit_acceptance_path(locale: :en, id: list)
      expect(page).to have_text ">>>"
    end
  end

  context "after list sent" do
    it "should indicate item changed" do
      list.update(sent_on: Time.now)
      list.items.first.update(price: 1000)
      visit edit_acceptance_path(locale: :en, id: list)
      expect(page).to have_text ">>>"
    end 
  end

end
