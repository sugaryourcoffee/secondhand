require 'spec_helper'

describe 'Edit item' do

  let(:active) { FactoryGirl.create(:active) }
  let(:user)   { FactoryGirl.create(:user) }
  let(:list)   { FactoryGirl.create(:list, event: active, user: user) }

  context "when accepted" do
    before do
      add_items_to_list(list, 2)
      accept(list)
    end

    it "should not be updated when in accepted list" do
      list.accepted?.should be_true
      item = list.items.first
      item.price = 123.5
      item.save
      item.errors.any?.should be_true
    end

    it "should not be updated when in cart" do
      cart = Cart.create!
      item = list.items.first
      line_item = cart.add(item)
      line_item.should_not be_nil
      expect { line_item.save }.to change(LineItem, :count).by(1)
      item.price = 432.50
      item.save
      item.errors.any?.should be_true
    end
  end

  context "when sold" do
    let(:selling) { create_selling_and_items(active, list, 2) }

    it "should not be updated" do
      item = selling.line_items.first.item
      item.price = 333.5
      item.save
      item.errors.any?.should be_true 
    end
  end

  context "when redeemed" do
    let(:selling)  { create_selling_and_items(active, list, 2) }
    let(:reversal) { create_reversal(active, selling, 0, 1) }

    it "should be updated when redeemed" do
      item = selling.line_items.first.item
      item.should eq reversal.line_items.first.item
      revoke_acceptance(item.list) 
      item.price = 444.5
      item.save
      item.errors.any?.should be_false
    end
  end

end
