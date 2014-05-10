require 'spec_helper'

describe Selling do
  
  it "should respond to items" do
    selling = Selling.new
    selling.should respond_to :items
    selling.should respond_to :to_pdf
  end

end
