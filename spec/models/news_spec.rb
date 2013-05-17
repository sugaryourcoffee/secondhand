require 'spec_helper'

describe News do
  before { @news = News.new(title: "Title", description: "Description") }

  subject { @news }

  it { should respond_to(:title) }
  it { should respond_to(:description) }

  it { should be_valid }

  describe "when title is not present" do
    before { @news.title = " " }
    it { should_not be_valid }
  end

  describe "when description is not present" do
    before { @news.description = " " }
    it { should_not be_valid }
  end
end
