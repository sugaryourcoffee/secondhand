require 'spec_helper'

describe List do
  let(:user)             { FactoryGirl.create(:user) }
  let(:event)            { FactoryGirl.create(:active) }
  let(:list)             { FactoryGirl.create(:list, user: user) }

  subject { list }

  it { is_expected.to respond_to(:list_number) }
  it { is_expected.to respond_to(:registration_code) }
  it { is_expected.to respond_to(:container) }
  it { is_expected.to respond_to(:event_id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:sent_on) }
  it { is_expected.to respond_to(:labels_printed_on) }

  it { is_expected.to be_valid }

  describe "without list number" do
    before { list.list_number = nil }
    it { is_expected.not_to be_valid }
  end

  describe "without registration code" do
    before { list.registration_code = nil }
    it { is_expected.not_to be_valid }
  end

  describe "without container color" do
    before { list.container = nil }
    it { is_expected.to be_valid }
  end

  describe "without event id" do
    before { list.event_id = nil }
    it { is_expected.not_to be_valid }
  end

  describe "without user id" do
    before { list.user_id = nil }
    it { is_expected.to be_valid }
  end

  describe "without sent_on" do
    before { list.user_id = nil }
    it { is_expected.to be_valid }
  end

  describe "simple search for list and registration code" do
    before do
      list.list_number = 12
      list.registration_code = "8a%s3/"
      list.save
    end

    it { expect(List.search("12")).not_to be_empty }
    it { expect(List.search("13")).to be_empty }
    it { expect(List.search("%s")).not_to be_empty }
    it { expect(List.search("1")).to be_empty }
  end

  describe "detailed search for list" do

    let!(:registered_list) { FactoryGirl.create(:list, event: event, 
                                                user: user, list_number: 1) }
    let!(:accepted_list)   { FactoryGirl.create(:accepted, 
                                                event: event, 
                                                user: user, list_number: 2) }

    it "should return accepted lists only" do
      event_id = event.id.to_s
      params = { "search_event_id" => event_id, "search_accepted_on" => '0' }

      search_conditions = List.search_conditions(params)

      expect(search_conditions).to eq ["event_id LIKE ? and accepted_on IS NOT ?", 
                                   "%#{event_id}%", nil]

      lists = List.where(search_conditions)
      expect(lists).not_to be_empty
      expect(lists).to eq [accepted_list]
    end

    it "should return not accepted lists only" do
      event_id = event.id.to_s
      params = { "search_event_id" => event_id, 
                 "search_accepted_on" => '1', 
                 "search_user_id" => '0' }

      search_conditions = List.search_conditions(params)

      expect(search_conditions).to eq ["event_id LIKE ? and accepted_on IS ? and user_id IS NOT ?", 
                                   "%#{event_id}%", nil, nil]

      lists = List.where(search_conditions)
      expect(lists).not_to be_empty
      expect(lists).to eq [registered_list]
    end

    it "should return registered lists" do
      event_id = event.id.to_s
      params = { "search_event_id" => event_id, "search_user_id" => '0' }

      search_conditions = List.search_conditions(params)

      expect(search_conditions).to eq ["event_id LIKE ? and user_id IS NOT ?", "%#{event_id}%", nil]

      lists = List.where(search_conditions)
      expect(lists).not_to be_empty
      expect(lists).to eq [registered_list, accepted_list]
    end
  end

  describe "export to CSV" do
    let!(:item) { list.items.create!(item_number: 1, description: "Ab;cd;ef",
                                    size: "ab;de", price: 2.5) }

    it "should not have ';' in any field" do
      expect(list.as_csv.split(';').size).to eq 16
    end
  end

  describe "cash up" do
    it "should return 0 for all values when no items sold" do
      expect(list.cash_up).to eq [0,0,0,0]
    end

    it "should return total = payback when total < 20 EUR" do
      create_selling_and_items(event, list, 3, [1,2,3])
      expect(list.cash_up).to eq [6,0,0,6]
    end

    it "should return total > payback when total >= 20 EUR" do
      create_selling_and_items(event, list, 3, [9,10,11])
      expect(list.cash_up).to eq [30,4.5,3,28.5]
    end

    it "should return values devisable by 0.5 without reminder" do
      create_selling_and_items(event, list, 5, [3,5,7,11,17])
      expect(list.cash_up).to eq [43,6.5,3,39.5]
    end
  end
end
