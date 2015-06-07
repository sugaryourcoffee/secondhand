class CounterController < ApplicationController

  def index
    @carts = Cart.not_empty
  end

end
