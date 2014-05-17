class Reversal < ActiveRecord::Base
  has_many :line_items
  has_many :sellings, through: :line_items
end
