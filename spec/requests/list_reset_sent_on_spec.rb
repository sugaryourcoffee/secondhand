require 'spec_helper'

describe 'List operation' do

  let(:active)   { FactoryGirl.create(:active) }
  let(:user)     { FactoryGirl.create(:user) }
  let(:admin)    { FactoryGirl.create(:admin) }
  let(:operator) { FactoryGirl.create(:operator) }
  let(:list)     { FactoryGirl.create(:assigned, event: active, user: user) }

  before do
    list.items.create!(item_attributes(item_number: 1, price: 22.5))
    list.update(sent_on: Time.now)
  end

  context "by list's owner" do
    before { sign_in user }

    describe "in user's view" do
      it "should reset sent_on when deleting item" do
        visit user_list_items_path(locale: :en, user_id: user, list_id: list)
        expect { click_link "Destroy" }.to change(Item, :count).by(-1)
        expect(list.reload.sent_on).to be_nil
      end

      it "should reset sent_on when editing item" do
        visit user_list_items_path(locale: :en, user_id: user, list_id: list)
        click_link "Edit"
        fill_in "Price", with: 1.5
        click_button "Update"
        expect(list.reload.sent_on).to be_nil
      end

      it "should reset sent_on when editing list" do
        visit user_path(locale: :en, id: user)
        fill_in "Enter container color", with: "Red"
        click_button "Save Container Color"
        expect(list.reload.sent_on).not_to be_nil
      end
    end

    describe "in model" do
      it "should reset sent_on when editing item" do
        list.items.first.update(price: 2.5, reset_list_sent_on: true)
        expect(list.reload.sent_on).to be_nil
      end

      it "should reset sent_on when deleting item" do
        item = list.items.first
        item.reset_list_sent_on = true
        expect { item.destroy }.to change(Item, :count).by(-1)
        expect(list.reload.sent_on).to be_nil
      end

      it "should not reset sent_on when editing list's container color" do
        list.update(container: "Red", reset_sent_on: true)
        expect(list.reload.sent_on).not_to be_nil
      end
    end
  end

  context "by operator" do
    before { sign_in operator }

    describe "in acceptance dialog" do
      before { visit edit_acceptance_path(locale: :en, id: list) } 
      
      it "should not reset sent_on when editing item", js: true do
        item = list.items.first
        click_link "edit-item-#{item.item_number}"
        fill_in "item_price", with: 2.5
        click_button "Update"
        expect(list.reload.sent_on).not_to be_nil
      end

      it "should not reset sent_on when deleting item", js: true do
        click_link "Delete"
        modal = page.driver.browser.switch_to.alert
        modal.accept
        expect(list.reload.sent_on).not_to be_nil
      end

      it "should not reset sent_on when editing list", js: true do
        click_link "edit_container"
        fill_in "Container", with: "Red"
        click_button "Update"
        expect(list.reload.sent_on).not_to be_nil
      end

      it "should not reset sent_on when accepting list" do
        click_button "Accept List"
        expect(list.reload.sent_on).not_to be_nil
      end
    end

    describe "in model" do
      it "should not reset sent_on when editing item" do
        list.items.first.update(price: 2.5)
        expect(list.reload.sent_on).not_to be_nil
      end

      it "should not reset sent_on when deleting item" do
        expect { list.items.first.destroy }.to change(Item, :count).by(-1)
        expect(list.reload.sent_on).not_to be_nil
      end

      it "should not reset sent_on when editing list" do
        list.update(container: "Red")
        expect(list.reload.sent_on).not_to be_nil
      end

      it "should not reset sent_on when accepting list" do
        list.update(accepted_on: Time.now)
        expect(list.reload.sent_on).not_to be_nil
      end
    end
  end

  context "by admin" do
    before { sign_in admin }

    describe "in user's view" do
      it "should not reset sent_on when deleting item" do
        visit user_list_items_path(locale: :en, user_id: user, list_id: list)
        expect { click_link "Destroy" }.to change(Item, :count).by(-1)
        expect(list.reload.sent_on).not_to be_nil
      end

      it "should not reset sent_on when editing item" do
        visit user_list_items_path(locale: :en, user_id: user, list_id: list)
        click_link "Edit"
        fill_in "Price", with: 1.5
        click_button "Update"
        expect(list.reload.sent_on).not_to be_nil
      end

      it "should not reset sent_on when editing list" do
        visit user_path(locale: :en, id: user)
        fill_in "Enter container color", with: "Red"
        click_button "Save Container Color"
        expect(list.reload.sent_on).not_to be_nil
      end

      it "should reset sent_on when deregistering list" do
        visit user_path(locale: :en, id: user)
        click_link "Deregister"
        expect(list.reload.sent_on).to be_nil
      end
    end

    describe "in acceptance dialog" do
      before { visit edit_acceptance_path(locale: :en, id: list.id) } 

      it "should not reset sent_on when deleting item", js: true do
        click_link "Delete", wait: 5
        modal = page.driver.browser.switch_to.alert
        modal.accept
        expect(list.reload.sent_on).not_to be_nil
      end

      it "should not reset sent_on when editing item", js: true do
#        puts "in editing item"
        item = list.items.first
        click_link "edit-item-#{item.item_number}", wait: 5
#        puts "clicked link edit-item"
        fill_in "item_price", with: 2.5
        click_button "Update"
#        puts list.sent_on.inspect
        expect(list.reload.sent_on).not_to be_nil
      end

      it "should not reset sent_on when editing list", js: true do
        click_link "edit_container"
        fill_in "Container", with: "Red"
        click_button "Update"
        expect(list.reload.sent_on).not_to be_nil
      end

      it "should not reset sent_on when accepting list"  do
        click_button "Accept List"
        expect(list.reload.sent_on).not_to be_nil
      end
    end

    describe "in model" do
      it "should not reset sent_on when editing item" do
        list.items.first.update(price: 2.5)
        expect(list.reload.sent_on).not_to be_nil
      end

      it "should not reset sent_on when deleting item" do
        expect { list.items.first.destroy }.to change(Item, :count).by(-1)
        expect(list.reload.sent_on).not_to be_nil
      end

      it "should not reset sent_on when editing list" do
        list.update(container: "Red")
        expect(list.reload.sent_on).not_to be_nil
      end

      it "should not reset sent_on when accepting list" do
        list.update(accepted_on: Time.now)
        expect(list.reload.sent_on).not_to be_nil
      end
    end
  end
end

