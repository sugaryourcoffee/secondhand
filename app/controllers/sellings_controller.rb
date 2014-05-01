class SellingsController < ApplicationController

  def index
    initialize_event_and_sellings
    @selling = Selling.find_by_id_and_event_id(params[:search_selling_id], @event)

    respond_to do |format|
      if @selling
        format.html { redirect_to edit_selling_path @selling } 
      else
        flash.now[:warning] = "Sorry, didn't find a selling with number " +
                              "#{params[:search_selling_id]}!" if params[:search_selling_id]
        format.html
      end
    end
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
    selling = Selling.find(params[:id])
    Item.where(selling_id: selling.id).update_all(selling_id: nil)
    selling.destroy
    initialize_event_and_sellings
    respond_to do |format|
      format.js
    end
  end

  private

    def initialize_event_and_sellings
      @event = Event.find_by_active(true)
      @sellings = Selling.find_all_by_event_id(@event)
    end
end
