class SellingsController < ApplicationController

  def index
    initialize_event_and_sellings
    @selling = Selling.find_by_id_and_event_id(params[:search_selling_id], 
                                               @event)

    respond_to do |format|
      if @selling
        format.html { redirect_to selling_path @selling } 
      else
        flash.now[:warning] = "Sorry, didn't find a selling with number " +
                "#{params[:search_selling_id]}!" if params[:search_selling_id]
        format.html
      end
    end
  end

  def show
    @event   = Event.find_by_active(true)
    @selling = Selling.find(params[:id])
  end

  def create
    @cart = current_cart
    if @cart.line_items.empty?
      redirect_to item_collection_carts_path, notice: "Your cart is empty"
      return
    end
    @selling = Selling.new(event_id: Event.find_by_active(true).id)
    @selling.add_items_from_cart(current_cart)
    respond_to do |format|
      if @selling.save
        Cart.destroy(session[:cart_id])
        session[:cart_id] = nil
        if system('lpr', @selling.to_pdf.to_path)
          format.html { redirect_to check_out_selling_path(@selling), 
                        notice: "Successfully created selling and printed" }
        else
          format.html { redirect_to check_out_selling_path(@selling), 
                        warning: "Successfully create selling but could not be printed" }
        end
      else
        format.html { redirect_to item_collection_carts_path, 
                      error: "Could not create selling" }
      end
    end
  end

  def print
    @selling = Selling.find(params[:id])
    respond_to do |format|
      if system('lpr', @selling.to_pdf.to_path)
        format.html { redirect_to :back,
                      notice: "Successfully printed selling #{@selling.id}" }
      else
        format.html { redirect_to :back,
                      warning: "Could not print selling #{@selling.id}" }
      end
    end
  end

  def check_out
    @selling = Selling.find(params[:id])
  end

  def delete_item
    @selling = Selling.find(params[:selling_id])
    item = Item.find(params[:id])

    respond_to do |format|
      if @selling.remove(item)
        flash.now[:success] = "Successfully removed item from selling"
      else
        flash.now[:error] = "Could not remove item from selling"
      end

      format.js   { redirect_to @selling }
      format.html { redirect_to @selling }
    end
  end

  def destroy
    selling = Selling.find(params[:id])
    initialize_event_and_sellings
    respond_to do |format|
      unless selling.destroy
        flash.now[:error] = "Cannot delete selling when containing items"
      end
      format.js
    end
  end

  private

    def initialize_event_and_sellings
      @event = Event.find_by_active(true)
      @sellings = Selling.find_all_by_event_id(@event)
    end
end
