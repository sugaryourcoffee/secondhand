require 'spec_helper'

describe List do
  let(:user) { FactoryGirl.create(:user) }
  let(:event) { FactoryGirl.create(:active) }
  let(:list) { FactoryGirl.create(:list, user: user) }

  subject { list }

  it { should respond_to(:list_number) }
  it { should respond_to(:registration_code) }
  it { should respond_to(:container) }
  it { should respond_to(:event_id) }
  it { should respond_to(:user_id) }
  it { should respond_to(:sent_on) }

  it { should be_valid }

  describe "without list number" do
    before { list.list_number = nil }
    it { should_not be_valid }
  end

  describe "without registration code" do
    before { list.registration_code = nil }
    it { should_not be_valid }
  end

  describe "without container color" do
    before { list.container = nil }
    it { should be_valid }
  end

  describe "without event id" do
    before { list.event_id = nil }
    it { should_not be_valid }
  end

  describe "without user id" do
    before { list.user_id = nil }
    it { should be_valid }
  end

  describe "without sent_on" do
    before { list.user_id = nil }
    it { should be_valid }
  end

  describe "simple search for list and registration code" do
    before do
      list.list_number = 12
      list.registration_code = "8a%s3/"
      list.save
    end

    it { List.search("12").should_not be_empty }
    it { List.search("13").should be_empty }
    it { List.search("%s").should_not be_empty }
    it { List.search("1").should be_empty }
  end

  describe "export to CSV" do
    let!(:item) { list.items.create!(item_number: 1, description: "Ab;cd;ef",
                                    size: "ab;de", price: 2.5) }

    it "should not have ';' in any field" do
      list.as_csv.split(';').size.should eq 16
    end
  end
end
