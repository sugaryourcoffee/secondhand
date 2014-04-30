class SellingsController < ApplicationController

  def index
    @event = Event.find_by_active(true)
    @sellings = Selling.find_all_by_event_id(@event)
    @selling = Selling.find_by_id_and_event_id(params[:search_selling_id], @event)

    respond_to do |format|
      if @selling
        format.html { redirect_to edit_selling_path @selling } 
      else
        flash[:warning] = "Sorry, didn't find a selling with number " +
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
  end

end
