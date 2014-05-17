class LineItem < ActiveRecord::Base
  belongs_to :item
  belongs_to :selling
  belongs_to :reversal
  belongs_to :cart

  attr_accessible :cart_id, :item_id, :reversal_id, :selling_id
end
