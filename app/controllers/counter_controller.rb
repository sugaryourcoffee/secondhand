class CounterController < ApplicationController

  def index
    @carts     = Cart.not_empty
    @sellings  = retrieve_sellings(params).paginate(page: params[:page], 
                                                    per_page: 10)
    @reversals = retrieve_reversals(params).paginate(page: params[:page], 
                                                     per_page: 10)
  end

  private

    def retrieve_sellings(params)
      if params[:selling_id] and not params[:selling_id].empty?
        Selling.where(id: params[:selling_id])
      else
        Selling.latest_on_top
      end
    end

    def retrieve_reversals(params)
      if params[:reversal_id] and not params[:reversal_id].empty?
        Reversal.where(id: params[:reversal_id])
      else
        Reversal.latest_on_top
      end
    end
end
