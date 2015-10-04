class AcceptancesController < ApplicationController

  skip_before_filter :authorize
  before_filter      :admin_or_operator

  def index
    @event = Event.find_by(active: true)
    
    if @event
      @list = List.find_by(list_number: params[:search_list_number], 
                           event_id:    @event) 
      unless @list and @list.registered?
        @lists = List.where(List.list_status_query_string(params[:filter]))
                     .order(:list_number)
                     .paginate(page: params[:page])
      end
    end

    respond_to do |format|
      if @list and @list.registered?
        format.html { redirect_to edit_acceptance_path @list }
      else
        if @list and !@list.registered?
          flash[:warning] = "List #{params[:search_list_number]} "+
                            "is not registered. "+
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
    render template: 'acceptances/edit_list.js.erb' 
#    respond_to do |format|
#      format.js
#    end
  end

  def update_list
    @list = List.find(params[:id])
    respond_to do |format|
      if @list.update_attributes(list_attributes) # params[:list])
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
      if @item.update_attributes(item_attributes) #params[:item])
        format.js
      else
        format.js { render 'edit_item' } 
      end
    end
  end

  def delete_item
    @item = Item.find(params[:id])
    @list = @item.list
    @item.destroy
    render template: 'acceptances/delete_item.js.erb' 
#    respond_to do |format|
#      format.js { render 'acceptances/delete_item.js.erb' }
#    end
  end

  # Toggles the accepted_on field to Nil or to the current time.
  def accept
    list = List.find(params[:id])

    list.accepted_on = list.accepted_on.nil? ? Time.now : nil

    respond_to do |format|
      if list.save
        if list.accepted_on.nil?
          flash[:success] = I18n.t('.released', 
                                   model: t('activerecord.models.list'), 
                                   list_number: list.list_number)
          format.html { redirect_to edit_acceptance_path(list) }
        else
          flash[:success] = I18n.t('.accepted', 
                                   model: t('activerecord.models.list'), 
                                   list_number: list.list_number)
          format.html { redirect_to acceptances_path }
        end
      else
        flash[:error] = I18n.t('.save_failed', 
                               model: t('activerecord.models.list'))
        format.html { redirect_to edit_acceptance_path(list) }
      end
    end
  end

  private

    def list_attributes
      params.require(:list).permit(:container)
    end

    def item_attributes
      params.require(:item).permit(:description, :item_number, :price, :size)
    end
end
