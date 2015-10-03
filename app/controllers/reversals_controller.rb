class ReversalsController < ApplicationController

  skip_before_filter :authorize,    only: [:create, :show, :check_out, :print]
  before_filter :admin_or_operator, only: [:create, :show, :check_out, :print]

  def index
    initialize_event_and_reversals
    @reversal = Reversal.find_by(id:       params[:search_reversal_id], 
                                 event_id: @event)

#    @reversal = Reversal.find_by_id_and_event_id(params[:search_reversal_id], 
#                                                 @event)

    respond_to do |format|
      if @reversal
        format.html { redirect_to @reversal} 
      else
        flash.now[:warning] = "Sorry, didn't find a redemption with number " +
               "#{params[:search_reversal_id]}!" if params[:search_reversal_id]
        format.html
      end
    end
  end

  def show
    @event   = Event.find_by(active: true) # find_by_active(true)
    @reversal = Reversal.find(params[:id])
  end

  def create
    @cart = current_reversal_cart
    if @cart.line_items.empty?
      redirect_to line_item_collection_carts_path, notice: "Your cart is empty"
      return
    end
    @reversal = Reversal.new(event_id: Event.find_by(active: true).id) #find_by_active(true).id)
    @reversal.add_items_from_cart(@cart)
    respond_to do |format|
      if @reversal.save
        Cart.destroy(session[:reversal_cart_id])
        session[:reversal_cart_id] = nil
        if system('lpr', @reversal.to_pdf("Gutschrift")) #.to_path)
          format.html { redirect_to check_out_reversal_path(@reversal), 
                        notice: "Successfully created redemption and printed" }
        else
          format.html { redirect_to check_out_reversal_path(@reversal), 
             alert: "Successfully create redemption but could not be printed" }
        end
      else
        format.html { redirect_to line_item_collection_carts_path, 
                      alert: "Could not create redemption" }
      end
    end
  end

  def check_out
    @reversal = Reversal.find(params[:id])
  end

  def print
    @reversal = Reversal.find(params[:id])
    respond_to do |format|
      if system('lpr', @reversal.to_pdf("Gutschrift")) #.to_path)
        format.html { redirect_to :back,
                      notice: "Printed redemption #{@reversal.id}" }
      else
        format.html { redirect_to :back,
                      alert: "Could not print redemption #{@reversal.id}" }
      end
    end

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
      @event = Event.find_by(active: true) # find_by_active(true)
      @reversals = Reversal.where(event_id: @event) # find_all_by_event_id(@event)
    end

end

