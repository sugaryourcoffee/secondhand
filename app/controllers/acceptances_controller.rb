class AcceptancesController < ApplicationController
  def index
    active_event = Event.find_by_active(true)
    list_number  = params[:search_list]
    @list = List.find_by_list_number_and_event_id(list_number, active_event) if params[:search_list]
    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit_list
    @list = List.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def edit_item
    @item = Item.find(params[:id])
    @list = @item.list
    respond_to do |format|
      format.js
    end
  end

end
