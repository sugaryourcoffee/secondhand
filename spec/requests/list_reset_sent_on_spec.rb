require 'spec_helper'

describe 'List operation' do

  let(:active)   { FactoryGirl.create(:active) }
  let(:user)     { FactoryGirl.create(:user) }
  let(:admin)    { FactoryGirl.create(:admin) }
  let(:operator) { FactoryGirl.create(:operator) }
  let(:list)     { FactoryGirl.create(:list, event: active, user: user) }

  before do
    add_items_to_list(list, 1)
    list.update(sent_on: Time.now)
  end

  context "by list's owner" do
    before { sign_in user }

    it "should reset sent_on when deleting item" do
      visit user_list_items_path(locale: :en, user_id: user, list_id: list)
      expect { click_link "Destroy" }.to change(Item, :count).by(-1)
      list.reload.sent_on.should be_nil
    end

    it "should reset sent_on when editing item" do
      visit user_list_items_path(locale: :en, user_id: user, list_id: list)
      click_link "Edit"
      fill_in "Price", with: 1.5
      click_button "Update"
      list.reload.sent_on.should be_nil
    end

    it "should reset sent_on when editing list" do
      visit user_path(locale: :en, id: user)
      fill_in "Enter container color", with: "Red"
      click_button "Save Container Color"
      list.reload.sent_on.should be_nil
    end
  end

  context "by operator" do
    before { sign_in operator }

    it "should not reset sent_on when deleting item" do
    end

    it "should not reset sent_on when editing item " do
    end

    it "should not reset sent_on when editing list" do
    end

    it "should not reset sent_on when accepting list" do
    end
  end

  context "by admin" do
    before { sign_in admin }

    it "should not reset sent_on when deleting item" do
    end

    it "should not reset sent_on when editing item " do
    end

    it "should not reset sent_on when editing list" do
    end

    it "should not reset sent_on when accepting list" do
    end

    it "should reset sent_on when deregistering list" do
    end
  end
end

