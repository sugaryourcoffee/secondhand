module EventsHelper
  def create_registration_codes(numbers, codes, size)
    numbers.each do |number|
      code = number.to_s.crypt("#{Random.new_seed}")[1..size]
      code = code.gsub(/O/, 'o').gsub(/0/, 'Q').gsub(/I/, 'i').gsub(/l/, 'L')
      redo if codes.find_index(code)
      codes.insert(number-1, code)
    end
    codes
  end
end
