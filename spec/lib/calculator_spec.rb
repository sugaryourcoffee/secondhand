require 'spec_helper'

describe Calculator do

  it "should round to 0.5" do
    expect(Calculator.round_base(1.24, 0.5)).to eq 1
    expect(Calculator.round_base(1.25, 0.5)).to eq 1.5
    expect(Calculator.round_base(1.74, 0.5)).to eq 1.5
    expect(Calculator.round_base(1.75, 0.5)).to eq 2
  end

  it "should round to 0.3" do
    expect(Calculator.round_base(0.14, 0.3)).to eq 0
    expect(Calculator.round_base(0.15, 0.3)).to eq 0.3
    expect(Calculator.round_base(0.44, 0.3)).to eq 0.3
    expect(Calculator.round_base(0.45, 0.3)).to eq 0.6

    expect(Calculator.round_base(0.74, 0.3)).to eq 0.6
    expect(Calculator.round_base(0.75, 0.3)).to eq 0.9
    expect(Calculator.round_base(1.04, 0.3)).to eq 0.9
    expect(Calculator.round_base(1.05, 0.3)).to eq 1.2
   end

  it "should should return the original value for base < 0" do
    expect(Calculator.round_base(1.24, -0.5)).to eq 1.24
  end

  it "should return the mimimum value" do
    expect(Calculator.round_minimum(1.24, 0.5, 2)).to eq 2
  end

end
