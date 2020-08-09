require 'spec_helper'

describe Page do

  it "should respond to attributes" do
    page = Page.new
    expect(page).to respond_to :number
    expect(page).to respond_to :title
    expect(page).to respond_to :content
  end

  it "should be valid with all attributes set" do
    page = Page.new(number: 1, title: "1", content: "1")
    expect(page.valid?).to be_truthy
    expect(page.errors.any?).to be_falsey
  end

  it "should not be valid without a page number" do
    page = Page.new(title: "1", content: "1")
    expect(page.valid?).to be_falsey
    expect(page.errors.any?).to be_truthy
  end

  it "should not be valid with a blank page number" do
    page = Page.new(number: nil, title: "1", content: "1")
    expect(page.valid?).to be_falsey
    expect(page.errors.any?).to be_truthy
  end

  it "should not be valid without a title" do
    page = Page.new(number: 1, title: "1")
    expect(page.valid?).to be_falsey
    expect(page.errors.any?).to be_truthy
  end

  it "should not be valid with a blank title" do
    page = Page.new(number: 1, title: "", content: "1")
    expect(page.valid?).to be_falsey
    expect(page.errors.any?).to be_truthy
  end

  it "should not be valid without a content" do
    page = Page.new(number: 1, content: "1")
    expect(page.valid?).to be_falsey
    expect(page.errors.any?).to be_truthy
  end

  it "should not be valid with a blank content" do
    page = Page.new(number: 1, title: "1", content: "")
    expect(page.valid?).to be_falsey
    expect(page.errors.any?).to be_truthy
  end

  it "should have unique pages per terms_of_use" do
    terms_of_use = TermsOfUse.create!(locale: :en)
    terms_of_use.pages.create!(number: 1, title: "1", content: "1")
    page = terms_of_use.pages.new(number: 1, title: "2", content: "2")
    expect(page.valid?).to be_falsey
    expect(page.errors.any?).to be_truthy
    terms_of_use2 = TermsOfUse.create!(locale: :de)
    page2 = terms_of_use2.pages.new(number: 1, title: "1", content: "1")
    expect(page2.valid?).to be_truthy
    expect(page2.errors.any?).to be_falsey
  end
end
