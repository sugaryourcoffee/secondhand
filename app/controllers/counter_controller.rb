class CounterController < ApplicationController

  def index
    @carts = Cart.not_empty
    @sellings = Selling.latest_on_top
  end

end
