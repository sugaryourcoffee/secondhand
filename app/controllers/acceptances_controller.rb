class AcceptancesController < ApplicationController

  def index
    @event = Event.find_by_active(true)
    
    if @event
      @list = List.find_by_list_number_and_event_id(params[:search_list_number], @event)
      unless @list and @list.registered?
        @lists = List.order(:list_number)
                     .paginate(page: params[:page],
                               conditions: List.list_status_query_string(params[:filter]))
      end
    end

    respond_to do |format|
      if @list and @list.registered?
        format.html { redirect_to edit_acceptance_path @list }
      else
        if @list and !@list.registered?
          flash[:warning] = "List #{params[:search_list_number]} is not registered. "+
                            "Acceptance is only possible for registered lists!"
        elsif @list.nil? and params[:search_list_number]
          flash[:warning] = "List #{params[:search_list_number]} doesn't exist!"
        end
        format.html
      end
    end
  end

  def edit
    @list = List.find(params[:id])
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

  def update_list
    @list = List.find(params[:id])
    respond_to do |format|
      if @list.update_attributes(params[:list])
        format.js
      else
        format.js { render 'edit_list' }
      end 
    end
  end

  def edit_item
    @item = Item.find(params[:id])
    @list = @item.list
    respond_to do |format|
      format.js
    end
  end

  def update_item
    @item = Item.find(params[:id])
    @list = @item.list
    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.js
      else
        format.js { render 'edit_item' } 
      end
    end
  end

  def delete_item
    item = Item.find(params[:id])
    @list = item.list
    item.destroy
    respond_to do |format|
      format.js 
    end
  end

  # Toggles the accepted_on field to Nil or to the current time.
  def accept
    list = List.find(params[:id])
    list.accepted_on = list.accepted_on.nil? ? Time.now : nil

    respond_to do |format|
      if list.save
        if list.accepted_on.nil?
          flash[:success] = I18n.t('.released', model: t('activerecord.models.list'))
          format.html { redirect_to edit_acceptance_path(list) }
        else
          flash[:success] = I18n.t('.accepted', model: t('activerecord.models.list'))
          format.html { redirect_to acceptances_path }
        end
      else
        flash[:error] = I18n.t('.save_failed', model: t('activerecord.models.list'))
        format.html { redirect_to edit_acceptance_path(list) }
      end
    end
  end

end
