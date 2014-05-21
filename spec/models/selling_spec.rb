require 'spec_helper'

describe Selling do
  
  it "should respond to attributes" do
    selling = Selling.new
    selling.should respond_to :line_items
    selling.should respond_to :to_pdf
  end

end
