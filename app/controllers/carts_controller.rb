class CartsController < ApplicationController

  skip_before_filter :authorize
  before_filter :admin_or_operator

  def index
    @carts = Cart.all
  end

  def show
    @cart = Cart.find(params[:id])
    @event = Event.find_by(active: true) # find_by_active(true)
    @transaction = @cart.cart_type
  end

  def update
    @cart  = current_reversal_cart
    @event = Event.find_by(active: true) # find_by_active(true)
    @list  = List.find_by(event_id: @event, list_number: params[:search_list_number]) # find_by_event_id_and_list_number(@event, params[:search_list_number])
    @item  = Item.find_by(list_id: @list, item_number: params[:search_item_number]) # find_by_list_id_and_item_number(@list, params[:search_item_number])
    @line_item = LineItem.sold(@item)
    
    respond_to do |format|
      if @line_item
        if @line_item.in_cart?(@cart)
          flash[:warning] = "Line item is already in cart"
        elsif @line_item.in_other_cart?(@cart)
          flash[:error] = "Line item is already in cart #{@line_item.cart.id}"
        else
          @cart.line_items << @line_item
          flash[:success] = "Successfully added item #{@item.item_number}"
        end
      else
        flash[:error] = "Cannot redeem unsold item"
      end
      format.js   { redirect_to line_item_collection_carts_path }
      format.html { redirect_to line_item_collection_carts_path }
    end
  end

  def destroy
    cart = Cart.find(params[:id])
    cart.destroy
    flash[:success] = "Successfully deleted cart #{cart.id}"
    redirect_to carts_path
  end

  def delete_item
    line_item = LineItem.find(params[:id])
    @cart = Cart.find(line_item.cart_id)

    respond_to do |format|
      if @cart.line_items.delete(line_item)
        flash[:success] = "Successfully removed item from cart"
      else
        flash[:error] = "Could not remove item from cart"
      end

      if @cart == current_reversal_cart
        format.js   { redirect_to line_item_collection_carts_path }
        format.html { redirect_to line_item_collection_carts_path }
      else
        format.js   { redirect_to @cart }
        format.html { redirect_to @cart }
      end
    end
  end

  def item_collection
    @event = Event.find_by(active: true) # find_by_active(true)
    @cart = current_cart
    @transaction = 'SALES'
  end

  def line_item_collection
    @event = Event.find_by(active: true) # find_by_active(true)
    @cart = current_reversal_cart
    @transaction = 'REDEMPTION'
  end
end
