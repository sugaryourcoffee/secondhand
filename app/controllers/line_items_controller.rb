class LineItemsController < ApplicationController

  skip_before_filter :authorize,    only: [:create, :destroy]
  before_filter :admin_or_operator, only: [:create, :destroy]

  def create
    @cart  = current_cart
    @event = Event.find_by_active(true)
    @list  = List.find_by_event_id_and_list_number(@event, 
                                                   params[:search_list_number])
    @item  = Item.find_by_list_id_and_item_number(@list, 
                                                  params[:search_item_number])
    @line_item = @cart.add(@item)
    
    respond_to do |format|
      if @line_item.save
        flash.now[:success] = "Successfully added item #{@item.item_number}"
        format.js   { redirect_to item_collection_carts_path }
        format.html { redirect_to item_collection_carts_path }
      else
        @cart = current_cart
        flash.now[:error] = "Could not add item"
        format.js   { render "carts/item_collection" }
        format.html { render "carts/item_collection" }
      end
    end
  end

  def destroy
    @line_item = LineItem.find(params[:id])

    respond_to do |format|
      if @line_item.destroy
        format.html { redirect_to item_collection_carts_path }
        format.js   { redirect_to item_collection_carts_path }
      else
        @cart = current_cart
        flash.now[:error] = "Could not delete item"
        format.html { render "carts/item_collection" }
        format.js   { render "carts/item_collection" }
      end
    end
  end

end
