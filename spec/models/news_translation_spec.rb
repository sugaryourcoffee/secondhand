require 'spec_helper'

describe NewsTranslation do
  before { @news_translation = NewsTranslation.new(title: "Title", 
                                        description: "Description",
                                        language: :de) }

  subject { @news_translation }

  it { should respond_to(:title) }
  it { should respond_to(:description) }
  it { should respond_to(:language) }
  it { should respond_to(:news_id) }

  it { should be_valid }

  describe "when title is not present" do
    before { @news_translation.title = " " }
    it { should_not be_valid }
  end

  describe "when description is not present" do
    before { @news_translation.description = " " }
    it { should_not be_valid }
  end

  describe "when language is not present" do
    before { @news_translation.language = " " }
    it { should_not be_valid }
  end

end
