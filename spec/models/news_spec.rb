require 'spec_helper'

describe News do
  let(:user) { FactoryGirl.create(:user) }
  let(:news) { FactoryGirl.create(:news) }

  subject { news }

  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:issue) }
  it { is_expected.to respond_to(:released) }
  it { is_expected.to respond_to(:promote_to_frontpage) }

  it { is_expected.to be_valid }

  describe "when user is not present" do
    before { news.user_id = nil }
    it { is_expected.not_to be_valid }
  end

  describe "when issue is not present" do
    before { news.issue = " " }
    it { is_expected.not_to be_valid }
  end
  
  describe "when released is false" do
    before { news.released = false }
    it { is_expected.to be_valid }
  end
  
  describe "when released is true" do
    before { news.released = true }
    it { is_expected.to be_valid }
  end

  describe "when promote_to_frontpage is false" do
    before { news.promote_to_frontpage = false }
    it { is_expected.to be_valid }
  end

  describe "when promote_to_frontpage is true" do
    before { news.promote_to_frontpage = true }
    it { is_expected.to be_valid }
  end
end
