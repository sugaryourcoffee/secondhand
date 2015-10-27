require 'spec_helper'

describe Importer do

  before do
    @data    = [ "Listnumber;5",
                 "Name;Sugar",
                 "First Name;Pierre",
                 "Street;Example Street 5",
                 "Zip Code;12345",
                 "Town;Example",
                 "Phone;1234567890",
                 "E-Mail;pierre@example.com",
                 "Container;-",
                 "Item;Description;Size;Price",
                 "1;One;1;1.0",
                 "2;Two;2;2.5",
                 ";Three;;",
                 "4;;;4.50",
                 "5;Five Two;;5.50",
                 "6;Six;66;6.60" ]
    @formats   = [/^\d$/, /\S/, /.*/, /^\d+\.[0|5]0?$|^\d+$/]
    @col_count = 4
    @header    = %w{ item description size price }

    @importer = Importer.new(@data, 
                             col_count: @col_count, 
                             header:    @header, 
                             formats:   @formats)
  end
  
  it "should raise error without data" do
    expect { Importer.new(nil, col_count: @col_count, 
                          header: @header, 
                          formats: @formats) }.to raise_error "data missing"
  end

  it "should raise error without column count" do
    expect { Importer.new(@data, 
                      header: @header, 
                      formats: @formats) }.to raise_error "column count missing"
  end

  it "should respond to row size" do
    @importer.row_count.should eq 3
  end

  it "should respond to column size" do
    @importer.col_count.should eq @col_count
  end

  it "should have header data" do
    @importer.header.should eq @header
  end

  it "should respond to item" do
    @importer.rows.first.item.should eq "1"
  end

  it "should respond to description" do 
    @importer.rows.first.description.should eq "One"
  end

  it "should respond to size" do
    @importer.rows.first.size.should eq "1"
  end

  it "should respond to price" do
    @importer.rows.first.price.should eq "1.0"
  end
end
