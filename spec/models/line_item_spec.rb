require 'spec_helper'

describe LineItem do
  
  it "should respond to attributes" do
    line_item = LineItem.new

    expect(line_item).to respond_to :item
    expect(line_item).to respond_to :cart
    expect(line_item).to respond_to :selling
    expect(line_item).to respond_to :reversal
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

        expect(line_item.in_cart?(cart)).to be_truthy # be_true

        expect(line_item.errors[:items].any?).to be_falsey # be_false
      end

      it "should not add nil to items" do
        line_item = add_item_to_cart(cart, nil)
        line_item.save

        expect(line_item.errors[:item_id].any?).to be_truthy # be_true
      end

      it "should not add items from not accepted lists" do
        line_item = add_item_to_cart(cart, list.items.first)
        line_item.save

        expect(line_item.errors[:items].any?).to be_truthy # be_true
      end

      it "should not add items contained in another cart" do
        cart_other = Cart.create
        other_line_item = add_item_to_cart(cart_other, 
                                                accepted_list.items.first)
        other_line_item.save

        expect(other_line_item.errors[:item].any?).to be_falsey # be_false

        expect(other_line_item.in_other_cart?(cart)).to be_truthy # be_true

        line_item = add_item_to_cart(cart, accepted_list.items.first)
        line_item.save

        expect(line_item.errors[:items].any?).to be_truthy # be_true
      end

      it "should not add sold items" do
        create_selling_and_items(event, accepted_list)

        line_item = add_item_to_cart(cart, accepted_list.items.first)
        line_item.save

        expect(line_item.errors[:item].any?).to be_truthy # be_true
      end

      it "should add an item only once" do
        line_item = add_item_to_cart(cart, accepted_list.items.first)
        line_item.save

        expect(line_item.errors[:item].any?).to be_falsey # be_false
        
        line_item_other = add_item_to_cart(cart, accepted_list.items.first)
        line_item_other.save

        expect(line_item_other.errors[:item].any?).to be_truthy # be_true

        expect(cart.line_items.reload.size).to eq 1
      end

      it "should delete item" do
        line_item = add_item_to_cart(cart, accepted_list.items.first)
        line_item.save

        cart.line_items eq [accepted_list.items.first]

        line_item.destroy
        expect(line_item.errors.any?).to be_falsey # be_false

        expect(cart.reload.line_items.empty?).to be_truthy # be_true
      end
    end

    context "with no active event" do

      let(:event)  { FactoryGirl.create(:event) }

      it "should not add items from accepted lists" do
        line_item = add_item_to_cart(cart, accepted_list.items.first)
        line_item.save

        expect(line_item.errors[:items].any?).to be_truthy # be_true
      end

      it "should not add items from not accepted lists" do
        line_item = add_item_to_cart(cart, list.items.first)
        line_item.save

        expect(line_item.errors[:items].any?).to be_truthy # be_true
      end

    end

  end

end
