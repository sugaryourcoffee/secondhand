require 'spec_helper'

describe Item do
  
  let(:user) { FactoryGirl.create(:user) }
  let(:event) { FactoryGirl.create(:active) }
  let(:list) { FactoryGirl.create(:list, user: user) }

  before do
    @item = list.items.build(item_number: 1, description: "Description", 
                             size: "123", price: 1.5)
  end

  subject { @item }

  it { expect(list.items.size).to eq(1) }
  it { is_expected.to respond_to(:item_number) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:size) }
  it { is_expected.to respond_to(:price) }
  it { is_expected.to respond_to(:list_id) }
  it { expect(@item.list).to eq(list) }
#  its(:list) { should == list }

  it { is_expected.to be_valid }

  describe "when list_id is not present" do
    before { @item.list_id = nil }
    it { is_expected.not_to be_valid }
  end

  describe "when description is not present" do
    before { @item.description = nil }
    it { is_expected.not_to be_valid }
  end

  describe "when size is not present" do
    before { @item.size = nil }
    it { is_expected.to be_valid }
  end

  describe "when price is not present" do
    before { @item.price = nil }
    it { is_expected.not_to be_valid }
  end

  describe "when price is less than 0.5" do
    before { @item.price = 0.4 }
    it { is_expected.not_to be_valid }
  end

  describe "when price is 0.5" do
    before { @item.price = 0.5 }
    it { is_expected.to be_valid }
  end

  describe "when price is not divisible by 0.5" do
    before { @item.price = 1.6 }
    it { is_expected.not_to be_valid }
  end

  describe "when price is zero" do
    before { @item.price = 0.0 }
    it { is_expected.not_to be_valid }
  end

#  describe "accessible attributes" do
#    it "should not allow access to list_id" do
#      expect do
#      Item.new(list_id: list.id)
#      end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
#    end
#  end

  describe "delete item" do
    it "should destroy item" do
      expect(list.items.size).to eq(1)
      list.items.destroy(@item)
      expect(list.items).to be_empty
    end
  end

end
