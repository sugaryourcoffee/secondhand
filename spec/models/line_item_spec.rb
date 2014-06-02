require 'spec_helper'

describe LineItem do
  
  it "should respond to attributes" do
    line_item = LineItem.new

    line_item.should respond_to :item
    line_item.should respond_to :cart
    line_item.should respond_to :selling
    line_item.should respond_to :reversal
  end

  describe "adding and removing items" do
    
    let(:seller)        { FactoryGirl.create(:user) }
    let(:list)          { FactoryGirl.create(:list, event: event) }
    let(:accepted_list) { FactoryGirl.create(:accepted, event: event, 
                                             user: seller) }
    let(:cart)          { Cart.create }
    
    before do
      add_items_to_list(list)
      add_items_to_list(accepted_list, 2)
    end

    context "with active event" do

      let(:event)  { FactoryGirl.create(:active) }

      it "should add items from accepted lists" do
        line_item = add_item_to_cart(cart, accepted_list.items.first)
        line_item.save

        line_item.in_cart?(cart).should be_true

        line_item.errors[:items].any?.should be_false
      end

      it "should not add nil to items" do
        line_item = add_item_to_cart(cart, nil)
        line_item.save

        line_item.errors[:item_id].any?.should be_true
      end

      it "should not add items from not accepted lists" do
        line_item = add_item_to_cart(cart, list.items.first)
        line_item.save

        line_item.errors[:items].any?.should be_true
      end

      it "should not add items contained in another cart" do
        cart_other = Cart.create
        other_line_item = add_item_to_cart(cart_other, 
                                                accepted_list.items.first)
        other_line_item.save

        other_line_item.errors[:items].any?.should be_false

        other_line_item.in_other_cart?(cart).should be_true

        line_item = add_item_to_cart(cart, accepted_list.items.first)
        line_item.save

        line_item.errors[:items].any?.should be_true
      end

      it "should not add sold items" do
        create_selling_and_items(event, accepted_list)

        line_item = add_item_to_cart(cart, accepted_list.items.first)
        line_item.save

        line_item.errors[:items].any?.should be_true
      end

      it "should add an item only once" do
        line_item = add_item_to_cart(cart, accepted_list.items.first)
        line_item.save

        line_item.errors[:items].any?.should be_false
        
        line_item_other = add_item_to_cart(cart, accepted_list.items.first)
        line_item_other.save

        line_item_other.errors[:items].any?.should be_true

        cart.line_items.reload.size.should eq 1
      end

      it "should delete item" do
        line_item = add_item_to_cart(cart, accepted_list.items.first)
        line_item.save

        cart.line_items eq [accepted_list.items.first]

        line_item.destroy
        line_item.errors.any?.should be_false

        cart.reload.line_items.empty?.should be_true
      end
    end

    context "with no active event" do

      let(:event)  { FactoryGirl.create(:event) }

      it "should not add items from accepted lists" do
        line_item = add_item_to_cart(cart, accepted_list.items.first)
        line_item.save

        line_item.errors[:items].any?.should be_true
      end

      it "should not add items from not accepted lists" do
        line_item = add_item_to_cart(cart, list.items.first)
        line_item.save

        line_item.errors[:items].any?.should be_true
      end

    end

  end

end
