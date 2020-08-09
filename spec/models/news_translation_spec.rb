require 'spec_helper'

describe NewsTranslation do
  before { @news_translation = NewsTranslation.new(title: "Title", 
                                        description: "Description",
                                        language: :de) }

  subject { @news_translation }

  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:language) }
  it { is_expected.to respond_to(:news_id) }

  it { is_expected.to be_valid }

  describe "when title is not present" do
    before { @news_translation.title = " " }
    it { is_expected.not_to be_valid }
  end

  describe "when description is not present" do
    before { @news_translation.description = " " }
    it { is_expected.not_to be_valid }
  end

  describe "when language is not present" do
    before { @news_translation.language = " " }
    it { is_expected.not_to be_valid }
  end

end
