require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the CartsHelper. For example:
#
# describe CartsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe CartsHelper do
  
  describe "split list and item number" do
    it "splits list and item number" do
      decoded = "002059"
      helper.split_list_and_item_number(decoded).should eq ["002","05"]
      decoded = "00205"
      helper.split_list_and_item_number(decoded).should eq ["00205"]
    end
  end

end
