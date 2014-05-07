class CartsController < ApplicationController

  def index
    @carts = Cart.all
  end

  def update
    @cart  = current_cart
    @event = Event.find_by_active(true)
    @list  = List.find_by_event_id_and_list_number(@event, params[:search_list_number])
    @item  = Item.find_by_list_id_and_item_number(@list, params[:search_item_number])
    
    respond_to do |format|
      if @cart.add(@item)
        flash.now[:success] = "Successfully added item #{@item.item_number}"
        format.js   { redirect_to item_collection_carts_path }
        format.html { redirect_to item_collection_carts_path }
      else
        flash.now[:error] = "Could not add item"
        format.js   { render action: "item_collection" }
        format.html { render action: "item_collection" }
      end
    end
  end

  def destroy
    cart = Cart.find(params[:id])
    cart.destroy
    flash[:success] = "Successfully deleted #{cart.id}"
    redirect_to carts_path
  end

  def delete_item
    item = Item.find(params[:id])
    @cart = current_cart

    respond_to do |format|
      if @cart.remove(item)
        flash.now[:success] = "Successfully removed item from cart"
      else
        flash.now[:error] = "Could not remove item from cart"
      end

      format.js   { redirect_to item_collection_carts_path }
      format.html { redirect_to item_collection_carts_path }
    end
  end

  def item_collection
    @event = Event.find_by_active(true)
    @cart = current_cart
  end
end
