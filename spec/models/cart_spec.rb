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

  describe "adding and removing items" do
    
    let(:seller)        { FactoryGirl.create(:user) }
    let(:list)          { FactoryGirl.create(:list, event: event) }
    let(:accepted_list) { FactoryGirl.create(:accepted, event: event, user: seller) }
    
    before do
      add_items_to_list(list)
      add_items_to_list(accepted_list, 2)
    end

    context "with active event" do

      let(:event)  { FactoryGirl.create(:active) }

=begin
      it "should add items from accepted lists" do
        cart = Cart.new
        cart.line_items << accepted_list.items.first
        cart.save

        cart.errors[:items].any?.should be_false
      end
=end

      it "should add items from accepted lists through add" do
        cart = Cart.create
        cart.add(accepted_list.items.first)

        cart.errors[:items].any?.should be_false
      end

      it "should not add nil to items through add" do
        cart = Cart.create
        cart.add(nil)

        cart.errors[:items].any?.should be_true
      end

=begin
      it "should not add items from not accepted lists" do
        cart = Cart.new
        cart.line_items << list.items.first
        cart.save

        cart.errors[:items].any?.should be_true
      end
=end

      it "should not add items from not accepted lists through add" do
        cart = Cart.create
        cart.add(list.items.first)

        cart.errors[:items].any?.should be_true
      end

      it "should not add items contained in another cart" do
        cart_other = Cart.create
        cart_other.add(accepted_list.items.first)

        cart_other.errors[:items].any?.should be_false

        cart = Cart.create
        cart.add(accepted_list.items.first)

        cart.errors[:items].any?.should be_true
      end

      it "should not add sold items" do
        create_selling_and_items(event, accepted_list)

        cart = Cart.create
        cart.add(accepted_list.items.first)

        cart.errors[:items].any?.should be_true
      end

      it "should add an item only once" do
        cart = Cart.new
        #cart.line_items << accepted_list.items.first
        cart.add(accepted_list.items.first)
        #cart.save

        cart.errors[:items].any?.should be_false
        
        #cart.line_items << accepted_list.items.first
        cart.add(accepted_list.items.first)
        #cart.save

        cart.errors[:items].any?.should be_true

        cart.reload.line_items.size.should eq 1
      end

      it "should add multiple items only once" do
        cart = Cart.new
        #cart.line_items << accepted_list.items.first
        cart.add(accepted_list.items.first)
        #cart.save

        cart.errors[:items].any?.should be_false
        
        #cart.line_items << accepted_list.items.first
        #cart.line_items << accepted_list.items.last
        cart.add(accepted_list.items.last)
        cart.add(accepted_list.items.first)
        #cart.save

        cart.errors[:items].any?.should be_true

        cart.reload.line_items.size.should eq 2
      end

      it "should delete item" do
        cart = Cart.new
        #cart.line_items << accepted_list.items.first
        cart.add(accepted_list.items.first)
        cart.save

        accepted_list.items.reload.first.cart_id.should_not be_nil

        cart.line_items eq [accepted_list.items.first]

        cart.remove(accepted_list.items.first).should be_true
        
        cart.line_items.empty?.should be_true

        accepted_list.reload.items.first.cart_id.should be_nil
      end
    end

    context "with no active event" do

      let(:event)  { FactoryGirl.create(:event) }

=begin
      it "should not add items from accepted lists" do
        cart = Cart.new
        cart.line_items << accepted_list.items.first
        cart.save

        cart.errors[:items].any?.should be_true
      end
=end

      it "should not add items from accepted lists through add" do
        cart = Cart.create
        cart.add(accepted_list.items.first)

        cart.errors[:items].any?.should be_true
      end

=begin
      it "should not add items from not accepted lists" do
        cart = Cart.new
        cart.line_items << list.items.first
        cart.save

        cart.errors[:items].any?.should be_true
      end
=end

      it "should not add items from not accepted lists through add" do
        cart = Cart.create
        cart.add(list.items.first)

        cart.errors[:items].any?.should be_true
      end

    end

  end

end
