require 'spec_helper'

describe EventsHelper do

  it "should not create codes with 'l', 'I', '0' and 'O'" do
    codes = []
    numbers = (1..300).to_a
    codes = create_registration_codes(numbers, codes, 7)
    
    expect(codes.size).to eq 300

    codes.each do |code|
      expect(code =~ /[l, I, 0, O]/).to be_nil
    end
  end

end
