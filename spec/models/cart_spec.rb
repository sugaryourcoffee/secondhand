require 'spec_helper'

describe Cart do

  it "should respond to line items" do
    cart = Cart.new
    cart.should respond_to :line_items
  end

  it "should respond to total" do
    cart = Cart.new
    cart.should respond_to :total
  end

  it "should respond to user" do
    cart = Cart.new
    cart.should respond_to :user
  end

  describe "adding and removing items" do
    
    let(:seller)        { FactoryGirl.create(:user) }
    let(:list)          { FactoryGirl.create(:list, event: event) }
    let(:accepted_list) { FactoryGirl.create(:accepted, event: event, 
                                             user: seller) }
    
    before do
      add_items_to_list(list)
      add_items_to_list(accepted_list, 2)
    end

    context "with active event" do

      let(:event)  { FactoryGirl.create(:active) }

      it "should add items from accepted lists through add" do
        cart = Cart.create
        line_item = cart.add(accepted_list.items.first)
        line_item.save

        line_item.errors[:items].any?.should be_falsey # be_false
      end

      it "should not add nil to items through" do
        cart = Cart.create
        line_item = cart.add(nil)
        line_item.save

        line_item.errors[:item_id].any?.should be_truthy # be_true
      end

      it "should not add items from not accepted lists" do
        cart = Cart.create
        line_item = cart.add(list.items.first)
        line_item.save

        line_item.errors[:items].any?.should be_truthy # be_true
      end

      it "should not add items contained in another cart" do
        cart_other = Cart.create
        line_item = cart_other.add(accepted_list.items.first)
        line_item.save

        line_item.errors[:items].any?.should be_falsey # be_false

        cart = Cart.create
        line_item = cart.add(accepted_list.items.first)
        line_item.save

        line_item.errors[:items].any?.should be_truthy # be_true
      end

      it "should not add sold items" do
        create_selling_and_items(event, accepted_list)

        cart = Cart.create
        line_item = cart.add(accepted_list.items.first)
        line_item.save

        line_item.errors[:item].any?.should be_truthy # be_true
      end

      it "should add an item only once" do
        cart = Cart.create
        line_item = cart.add(accepted_list.items.first)
        line_item.save

        line_item.errors[:item].any?.should be_falsey # be_false
        
        line_item = cart.add(accepted_list.items.first)
        line_item.save

        line_item.errors[:item].any?.should be_truthy # be_true

        cart.reload.line_items.size.should eq 1
      end

      it "should add multiple items only once" do
        cart = Cart.create
        line_item = cart.add(accepted_list.items.first)
        line_item.save

        line_item.errors[:item].any?.should be_falsey # be_false
        
        line_item = cart.add(accepted_list.items.last)
        line_item.save

        line_item.errors[:item].any?.should be_falsey # be_false

        line_item = cart.add(accepted_list.items.first)
        line_item.save

        line_item.errors[:item].any?.should be_truthy # be_true

        cart.reload.line_items.size.should eq 2
      end

      it "should delete item" do
        cart = Cart.create
        line_item = cart.add(accepted_list.items.first)
        line_item.save

        cart.line_items eq [line_item]

        line_item.destroy
        
        cart.reload.line_items.empty?.should be_truthy # be_true
      end
    end

    context "with no active event" do

      let(:event)  { FactoryGirl.create(:event) }

      it "should not add items from accepted lists through add" do
        cart = Cart.create
        line_item = cart.add(accepted_list.items.first)
        line_item.save

        line_item.errors[:items].any?.should be_truthy # be_true
      end

      it "should not add items from not accepted lists through add" do
        cart = Cart.create
        line_item = cart.add(list.items.first)
        line_item.save

        line_item.errors[:items].any?.should be_truthy # be_true
      end

    end

  end

end
