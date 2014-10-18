# Provides helper functions for mathematical operations
module Calculator

  # Rounds a given number to the base provided. The base can be any positive
  # number.
  #
  #      A base of 0.5 will round a given number in 0.5 steps.
  #      0.24 -> 0.00
  #      0.25 -> 0.50
  #      0.74 -> 0.50
  #      0.75 -> 1.00
  #
  #      A base of 0.3 will round a given number in 0.3 steps.
  #      0.14 -> 0.00
  #      0.15 -> 0.30
  #      0.44 -> 0.30
  #      0.45 -> 0.60
  #
  #   round_base(1.04, 0.3, 1) -> 0.9
  #
  # value::     number to be rounded
  # base::      base that determines how to round. A base less or equal 0 will
  #             return the original number
  # precision:: rounding precision of decimals
  def Calculator.round_base(value, base, precision = 1)
    return value if base <= 0
    offset = value % base
    floor  = value - offset
    return (floor + 2 * base).round(precision) if offset >= 1.5 * base
    return (floor + base).round(precision)     if offset >= 0.5 * base
    floor.round(precision)
  end

  # Rounds a given number to the base provided. The least number is the 
  # minimum value. The base can be any positive number.
  #
  #      A base of 0.5 will round a given number in 0.5 steps.
  #      0.00 -> 0.50
  #      0.25 -> 0.50
  #      0.74 -> 0.50
  #      0.75 -> 1.00
  #
  #      A base of 0.3 will round a given number in 0.3 steps.
  #      0.14 -> 0.30
  #      0.15 -> 0.30
  #      0.44 -> 0.30
  #      0.45 -> 0.60
  #
  #   round_minimum(1.04, 0.3, 1.2, 1) -> 1.2
  #
  # value::     number to be rounded
  # base::      base that determines how to round. A base less or equal 0 will
  #             return the original number
  # minimum::   minimum the minimum number to be returned
  # precision:: rounding precision of decimals
  def Calculator.round_minimum(value, base, minimum = 0, precision = 1)
    rounded = round_base(value, base)
    return [rounded, minimum].max if rounded < minimum
  end

end
