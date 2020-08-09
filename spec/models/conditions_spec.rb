require 'spec_helper'

describe Conditions do

  it "should respond to attributes" do
    conditions = Conditions.new
    expect(conditions).to respond_to :version
    expect(conditions).to respond_to :active
  end

  it "should have a version" do
    conditions = Conditions.new(version: "01/2016")
    expect(conditions.valid?).to be_truthy
    expect(conditions.errors.any?).to be_falsey
  end

  it "should not be valid without a version" do
    conditions = Conditions.new
    expect(conditions.valid?).to be_falsey
    expect(conditions.errors.any?).to be_truthy
  end

  it "should not be valid with a blank version" do
    conditions = Conditions.new(version: "")
    expect(conditions.valid?).to be_falsey
    expect(conditions.errors.any?).to be_truthy
  end

  it "should have unique versions" do
    Conditions.create!(version: "01/2016")
    conditions = Conditions.new(version: "01/2016")
    expect(conditions.valid?).to be_falsey
    expect(conditions.errors.any?).to be_truthy
    conditions2 = Conditions.new(version: "02/2016")
    expect(conditions2.valid?).to be_truthy
    expect(conditions2.errors.any?).to be_falsey
  end

end
