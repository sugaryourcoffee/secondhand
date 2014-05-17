require 'spec_helper'

describe LineItem do
  
  it "should respond to attributes" do
    line_item = LineItem.new

    line_item.should respond_to :item
    line_item.should respond_to :reversal

  end

end
