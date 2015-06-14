class CounterController < ApplicationController

  def index
    @event     = Event.find_by_active(true)
    @carts     = Cart.not_empty
    @sellings  = retrieve_sellings(params).paginate(page: params[:page], 
                                                    per_page: 10)
    @reversals = retrieve_reversals(params).paginate(page: params[:page], 
                                                     per_page: 10)
  end

  private

    def retrieve_sellings(params)
      if params[:selling_id] and not params[:selling_id].empty?
        Selling.where(id: params[:selling_id], event_id: @event)
      else
        Selling.where(event_id: @event).latest_on_top
      end
    end

    def retrieve_reversals(params)
      if params[:reversal_id] and not params[:reversal_id].empty?
        Reversal.where(id: params[:reversal_id], event_id: @event)
      else
        Reversal.where(event_id: @event).latest_on_top
      end
    end
end
