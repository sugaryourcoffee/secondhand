class ItemsController < ApplicationController

  skip_before_filter :authorize, 
                 only: [:index, :new, :create, :destroy, :show, :edit, :update]

  before_filter :correct_user, :set_instance_vars

  def index
    @items = Item.where({ list_id: params[:list_id] }).order(:item_number)
    @list = List.find(params[:list_id])
    @user = User.find(params[:user_id])
  end

  def new
    @list = List.find(params[:list_id])
    if @list.max_items_per_list?
      flash[:warning] = I18n.t('.list_full', list_number: @list.list_number)
      redirect_to root_path
    elsif @list.accepted_on
      flash[:warning] = I18n.t('.list_accepted_new', 
                               list_number: @list.list_number)
      redirect_to current_user
    end
    @item = Item.new
    @user = User.find(params[:user_id])
  end

  def create
    @list = List.find(params[:list_id])
    @item = @list.items.build(item_params) # params[:item])
    @user = User.find(params[:user_id])
    if @item.save
      flash[:success] = I18n.t('.created', model: t('activerecord.models.item'))
      if params[:commit] == I18n.t('.items.form.create_and_new')
        redirect_to new_user_list_item_path(@user, @list)
      else
        redirect_to user_list_items_path(@user, @list)
      end
    else
      flash[:error] = I18n.t('.not_created', 
                             model: t('activerecord.models.item'))
      render 'new'
    end 
  end

  def show
    @item = Item.find(params[:id])
    @list = List.find(params[:list_id])
    @user = User.find(params[:user_id]) 
  end

  def edit
    @item = Item.find(params[:id])
    @list = List.find(params[:list_id])
    @user = User.find(params[:user_id])
    if @list.accepted_on
      flash[:warning] = I18n.t('.list_accepted_edit', 
                               list_number: @list.list_number)
      redirect_to current_user
    end
  end

  def update
    respond_to do |format|
      if @item.update_attributes(item_params) # params[:item])
        return_url = request.referer.include?("/items/") ? 
                     user_list_items_path(@user, @list) : request.referer
        format.html { redirect_to return_url, 
                      notice: I18n.t('.updated', 
                                     model: t('activerecord.models.item')) }
        format.js { redirect_to return_url }
      else
        flash[:error] = I18n.t('.not_updated', 
                               model: t('activerecord.models.item'))
        if request.referer.include?("/items/")
          format.html { render action: 'edit' } 
        else
          format.js { redirect_to request.referer }
        end
      end  
    end
  end

  def destroy
    @list = List.find(params[:list_id])
    item = Item.find(params[:id])
    if @list.accepted_on
      flash[:warning] = I18n.t('.list_accepted_destroy', 
                               list_number: @list.list_number)
      redirect_to current_user
    else
      item.destroy
      flash[:success] = I18n.t('.destroyed', 
                               model: t('activerecord.models.item'))
      @user = User.find(params[:user_id])
      redirect_to user_list_items_path(@user, @list)
    end
  end

  private

    def item_params
      params.require(:item).permit(:description, :item_number, :price, :size)
    end

    def correct_user
      user = User.find(params[:user_id])

      users_list = List.find(params[:list_id]).user_id == user.id
      
      unless users_list or current_user.admin?
        flash[:warning] = I18n.t('.list_not_assigned', 
                                 model: t('activerecord.models.item'))
        redirect_to(root_path)
      end
    end

    def set_instance_vars
      @item = Item.find(params[:id]) if params[:id]
      @list = List.find(params[:list_id])
      @user = User.find(params[:user_id])
    end

end
