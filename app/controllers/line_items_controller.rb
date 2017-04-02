class LineItemsController < ApplicationController

  skip_before_filter :authorize,    only: [:create, :destroy]
  before_filter :admin_or_operator, only: [:create, :destroy]

  def create
    @cart  = current_cart
    @event = Event.find_by(active: true)
    event = params[:search_list_number].slice!(/^#{@event.id}/)
    @list  = List.find_by(event_id:    @event, 
                          list_number: params[:search_list_number])
    @item  = Item.find_by(list_id:     @list, 
                          item_number: params[:search_item_number])
    @line_item = @cart.add(@item)
    
    respond_to do |format|
      if event && @line_item.save
        format.js   { redirect_to item_collection_carts_path }
        format.html { redirect_to item_collection_carts_path }
      else
        message = I18n.t('could_not_add_item')

        if params[:search_list_number].blank?
          message << I18n.t('list_must_not_be_empty')
        elsif event.nil?
          message << I18n.t('label_from_other_event')
        elsif @list.nil?
          message << I18n.t('list_not_existing', 
                            number: params[:search_list_number])
        elsif params[:search_item_number].blank?
          message << I18n.t('item_must_not_be_empty')
        elsif @item.nil?
          if @list.accepted?
            message << I18n.t('item_not_existing', 
                              number: params[:search_item_number])
          else
            message << I18n.t('list_not_accepted', 
                              number: params[:search_list_number])
         end
        else
          message << @line_item.errors.full_messages.join(',')
        end
        flash[:error] = message
        format.js   { redirect_to item_collection_carts_path }
        format.html { redirect_to item_collection_carts_path }
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
