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

  describe "when item_number is not present" do
    before { @item.item_number = nil }
    it { should_not be_valid }
  end

  describe "when description is not present" do
    before { @item.description = nil }
    it { should_not be_valid }
  end

  describe "when size is not present" do
    before { @item.size = nil }
    it { should be_valid }
  end

  describe "when price is not present" do
    before { @item.price = nil }
    it { should_not be_valid }
  end

  describe "when price is less than 0.5" do
    before { @item.price = 0.4 }
    it { should_not be_valid }
  end

  describe "when price is 0.5" do
    before { @item.price = 0.5 }
    it { should be_valid }
  end

  describe "when price is not divisible by 0.5" do
    before { @item.price = 1.6 }
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
