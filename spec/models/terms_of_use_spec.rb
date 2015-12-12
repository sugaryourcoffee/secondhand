require 'spec_helper'

describe TermsOfUse do

  it "should respond to attributes" do
    terms_of_use = TermsOfUse.new
    terms_of_use.should respond_to :locale
  end

  it "should be valid when all attributes set" do
    terms_of_use = TermsOfUse.new(locale: "en")
    terms_of_use.valid?.should be_truthy
    terms_of_use.errors.any?.should be_falsey
  end

  it "should not be valid without a locale" do
    terms_of_use = TermsOfUse.new
    terms_of_use.valid?.should be_falsey
    terms_of_use.errors.any?.should be_truthy
  end

  it "should not be valid with a blank locale" do
    terms_of_use = TermsOfUse.new(locale: "")
    terms_of_use.valid?.should be_falsey
    terms_of_use.errors.any?.should be_truthy
  end

  it "should allow each locale only once per conditions" do
    conditions = Conditions.create!(version: "01/2016")
    conditions.terms_of_uses.create!(locale: :de)
    conditions.terms_of_uses.create!(locale: "en")
    terms_of_use_en = conditions.terms_of_uses.new(locale: :en)
    terms_of_use_en.valid?.should be_falsey
    terms_of_use_en.errors.any?.should be_truthy
    conditions2 = Conditions.create!(version: "02/2016")
    terms_of_use_en2 = conditions2.terms_of_uses.new(locale: :en)
    terms_of_use_en2.valid?.should be_truthy
    terms_of_use_en2.errors.any?.should be_falsey
  end
end
