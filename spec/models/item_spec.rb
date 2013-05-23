require 'spec_helper'

describe Item do
  
  let(:user) { FactoryGirl.create(:user) }
  let(:event) { FactoryGirl.create(:active) }
  let(:list) { FactoryGirl.create(:list, user: user) }

  before do
    @item = list.items.build(item_number: 1, description: "Description", size: "123", price: 1.5)
  end

  subject { @item }

  it { should respond_to(:item_number) }
  it { should respond_to(:description) }
  it { should respond_to(:size) }
  it { should respond_to(:price) }
  it { should respond_to(:list_id) }
  its(:list) { should == list }

  it { should be_valid }

  describe "when list_id is not present" do
    before { @item.list_id = nil }
    it { should_not be_valid }
  end

  describe "accessible attributes" do
    it "should not allow access to list_id" do
      expect do
        Item.new(list_id: list.id)
      end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
end
