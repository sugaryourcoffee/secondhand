require 'spec_helper'

describe News do
  let(:user) { FactoryGirl.create(:user) }
  let(:news) { FactoryGirl.create(:news) }

  subject { news }

  it { should respond_to(:user) }
  it { should respond_to(:issue) }
  it { should respond_to(:released) }
  it { should respond_to(:promote_to_frontpage) }

  it { should be_valid }

  describe "when user is not present" do
    before { news.user_id = nil }
    it { should_not be_valid }
  end

  describe "when issue is not present" do
    before { news.issue = " " }
    it { should_not be_valid }
  end
  
  describe "when released is not present" do
    before { news.released = nil }
    it { should_not be_valid }
  end

  describe "when promote_to_frontpage is not present" do
    before { news.promote_to_frontpage = nil }
    it { should_not be_valid }
  end
end
