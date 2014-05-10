class LineItem < ActiveRecord::Base
  attr_accessible :cart_id, :item_id, :reversal_id
end
