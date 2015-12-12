require 'spec_helper'

describe Page do

  it "should respond to attributes" do
    page = Page.new
    page.should respond_to :number
    page.should respond_to :title
    page.should respond_to :content
  end

  it "should be valid with all attributes set" do
    page = Page.new(number: 1, title: "1", content: "1")
    page.valid?.should be_truthy
    page.errors.any?.should be_falsey
  end

  it "should not be valid without a page number" do
    page = Page.new(title: "1", content: "1")
    page.valid?.should be_falsey
    page.errors.any?.should be_truthy
  end

  it "should not be valid with a blank page number" do
    page = Page.new(number: nil, title: "1", content: "1")
    page.valid?.should be_falsey
    page.errors.any?.should be_truthy
  end

  it "should not be valid without a title" do
    page = Page.new(number: 1, title: "1")
    page.valid?.should be_falsey
    page.errors.any?.should be_truthy
  end

  it "should not be valid with a blank title" do
    page = Page.new(number: 1, title: "", content: "1")
    page.valid?.should be_falsey
    page.errors.any?.should be_truthy
  end

  it "should not be valid without a content" do
    page = Page.new(number: 1, content: "1")
    page.valid?.should be_falsey
    page.errors.any?.should be_truthy
  end

  it "should not be valid with a blank content" do
    page = Page.new(number: 1, title: "1", content: "")
    page.valid?.should be_falsey
    page.errors.any?.should be_truthy
  end

  it "should have unique pages per terms_of_use" do
    terms_of_use = TermsOfUse.create!(locale: :en)
    terms_of_use.pages.create!(number: 1, title: "1", content: "1")
    page = terms_of_use.pages.new(number: 1, title: "2", content: "2")
    page.valid?.should be_falsey
    page.errors.any?.should be_truthy
    terms_of_use2 = TermsOfUse.create!(locale: :de)
    page2 = terms_of_use2.pages.new(number: 1, title: "1", content: "1")
    page2.valid?.should be_truthy
    page2.errors.any?.should be_falsey
  end
end
