require 'spec_helper'

describe Conditions do

  it "should respond to attributes" do
    conditions = Conditions.new
    conditions.should respond_to :version
    conditions.should respond_to :active
  end

  it "should have a version" do
    conditions = Conditions.new(version: "01/2016")
    conditions.valid?.should be_truthy
    conditions.errors.any?.should be_falsey
  end

  it "should not be valid without a version" do
    conditions = Conditions.new
    conditions.valid?.should be_falsey
    conditions.errors.any?.should be_truthy
  end

  it "should not be valid with a blank version" do
    conditions = Conditions.new(version: "")
    conditions.valid?.should be_falsey
    conditions.errors.any?.should be_truthy
  end

  it "should have unique versions" do
    Conditions.create!(version: "01/2016")
    conditions = Conditions.new(version: "01/2016")
    conditions.valid?.should be_falsey
    conditions.errors.any?.should be_truthy
    conditions2 = Conditions.new(version: "02/2016")
    conditions2.valid?.should be_truthy
    conditions2.errors.any?.should be_falsey
  end

end
