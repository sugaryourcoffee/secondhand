class ReversalsController < ApplicationController

  def index
    initialize_event_and_reversals
    @redemption = Reversal.find_by_id_and_event_id(params[:search_redemption_id], @event)

    respond_to do |format|
      if @redemption
        format.html { redirect_to redemption_path @redemption } 
      else
        flash.now[:warning] = "Sorry, didn't find a selling with number " +
                              "#{params[:search_selling_id]}!" if params[:search_redemption_id]
        format.html
      end
    end
  end

  def show
    @event   = Event.find_by_active(true)
    @redemption = Reversal.find(params[:id])
  end

  def create
    @cart = current_reversal_cart
    if @cart.line_items.empty?
      redirect_to line_item_collection_carts_path, notice: "Your cart is empty"
      return
    end
    @reversal = Reversal.new(event_id: Event.find_by_active(true).id)
    @reversal.add_items_from_cart(@cart)
    respond_to do |format|
      if @reversal.save
        Cart.destroy(session[:reversal_cart_id])
        session[:reversal_cart_id] = nil
        if system('lpr', @reversal.to_pdf.to_path)
          format.html { redirect_to check_out_reversal_path(@reversal), 
                        notice: "Successfully created redemption and printed" }
        else
          format.html { redirect_to check_out_selling_path(@reversal), 
                        warning: "Successfully create redemption but could not be printed" }
        end
      else
        format.html { redirect_to line_item_collection_carts_path, 
                      error: "Could not create redemption" }
      end
    end
  end

  def check_out
    @reversal = Reversal.find(params[:id])
  end

  def destroy
    reversal = Reversal.find(params[:id])
    initialize_event_and_reversals
    respond_to do |format|
      unless reversal.destroy
        flash.now[:error] = "Cannot delete redemption when containing items"
      end
      format.js
    end
  end

  private

    def initialize_event_and_reversals
      @event = Event.find_by_active(true)
      @reversals = Reversal.find_all_by_event_id(@event)
    end

end

