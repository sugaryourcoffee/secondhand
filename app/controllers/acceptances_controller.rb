# frozen_string_literal: true

# no comment
class AcceptancesController < ApplicationController
  skip_before_filter :authorize
  before_filter      :admin_or_operator

  helper_method :sort_column, :sort_direction

  def index
    @event = Event.find_by(active: true)
    if @event
      @list = List.find_by(list_number: params[:search_acceptance_list_number],
                           event_id: @event)
      unless @list&.registered? # && @list.registered?
        @lists = List.where(List.list_status_query_string(params[:filter]))
                     .order(:list_number)
                     .paginate(page: params[:page])
      end
    end

    respond_to do |format|
      if @list&.registered? # @list && @list.registered?
        format.html { redirect_to edit_acceptance_path @list }
      else
        if @list && !@list.registered?
          flash[:warning] = "List #{params[:search_acceptance_list_number]} " \
                            'is not registered. ' \
                            'Acceptance is only possible for registered lists!'
        elsif @list.nil? && params[:search_acceptance_list_number]
          flash[:warning] = "List #{params[:search_acceptance_list_number]} " \
                            "doesn't exist!"
        end
        format.html
      end
    end
  end

  def edit
    load_list_and_items
    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit_list
    load_list
    # render template: 'acceptances/edit_list.js.erb'
    respond_to(:js)
    # respond_to do |format|
    #   format.js
    # end
  end

  def update_list
    load_list
    respond_to do |format|
      if @list.update_attributes(list_attributes)
        format.js
      else
        format.js { render 'edit_list' }
      end
    end
  end

  def edit_item
    load_item_and_list
    load_items(@list)
    respond_to(:js)
    # respond_to do |format|
    #   format.js
    # end
  end

  def update_item
    load_item_and_list
    load_items(@list)
    respond_to do |format|
      if @item.update_attributes(item_attributes)
        format.js
      else
        format.js { render 'edit_item' }
      end
    end
  end

  def delete_item
    load_item_and_list
    load_items(@list)
    @item.destroy
    render template: 'acceptances/delete_item.js.erb'
  end

  # Toggles the accepted_on field to Nil or to the current time.
  def accept
    load_list

    if @list.acceptable?
      accept_list
    else
      flash[:error] = I18n.t('.missing_container_color')
      redirect_to edit_acceptance_path(@list)
    end
  end

  private

  def accept_list
    @list.accepted_on = @list.accepted_on.nil? ? Time.now : nil

    respond_to do |format|
      if @list.save
        if @list.accepted_on.nil?
          flash[:success] = I18n.t('.released',
                                   model: t('activerecord.models.list'),
                                   list_number: @list.list_number)
          format.html { redirect_to edit_acceptance_path(@list) }
        else
          flash[:success] = I18n.t('.accepted',
                                   model: t('activerecord.models.list'),
                                   list_number: @list.list_number)
          format.html { redirect_to acceptances_path }
        end
      else
        flash[:error] = I18n.t('.save_failed',
                               model: t('activerecord.models.list'))
        format.html { redirect_to edit_acceptance_path(@list) }
      end
    end
  end

  def list_attributes
    params.require(:list).permit(:container)
  end

  def item_attributes
    params.require(:item).permit(:description, :item_number, :price, :size)
  end

  def sort_column
    Item.column_names.include?(params[:sort]) ? params[:sort] : 'item_number'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def load_list_and_items
    @list  = List.find(params[:id])
    @items = @list.items.order("#{sort_column} #{sort_direction}")
  end

  def load_list
    @list = List.find(params[:id])
  end

  def load_items(list)
    @items = list.items.order("#{sort_column} #{sort_direction}")
  end

  def load_item_and_list
    @item = Item.find(params[:id])
    @list = @item.list
  end
end
