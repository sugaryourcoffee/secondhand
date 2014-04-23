class AcceptancesController < ApplicationController
  def index
    active_event = Event.find_by_active(true)
    list_number  = params[:search_list]
    @list = List.find_by_list_number_and_event_id(list_number, active_event)

    respond_to do |format|
      unless list_number.nil?
        if @list.nil?
          flash.now[:warning] = I18n.t('.no_list',
                                       model: t('activerecord.models.list'))
        elsif not @list.registered?
          flash.now[:warning] = I18n.t('.unregistered', 
                                       model: t('activerecord.models.list'))
        end
      end
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

  def accept
    list = List.find(params[:id])
    list.accepted_on = Time.now
    if list.save
      flash[:success] = I18n.t('.accepted', model: t('activerecord.models.list'))
    else
      flash[:error] = I18n.t('.save_failed', model: t('activerecord.models.list'))
    end
    redirect_to acceptances_path
  end

end
