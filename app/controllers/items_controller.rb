class ItemsController < ApplicationController

  skip_before_filter :authorize, only: [:index, :new, :create, :destroy, 
                                        :show, :edit, :update]

  before_filter :correct_user, :set_instance_vars

  def index
    @items = Item.where({ list_id: params[:list_id] }).order(:item_number).all
    @list = List.find(params[:list_id])
    @user = User.find(params[:user_id])
  end

  def new
    @item = Item.new
    @list = List.find(params[:list_id])
    @user = User.find(params[:user_id])
  end

  def create
    @list = List.find(params[:list_id])
    @item = @list.items.build(params[:item])
    @user = User.find(params[:user_id])
    if @item.save
      flash[:success] = I18n.t('.created', 
                               model: t('activerecord.models.item'))
      redirect_to user_list_items_path(@user, @list)
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
  end

  def update
    if @item.update_attributes(params[:item])
      flash[:success] = I18n.t('.updated', model: t('activerecord.models.item'))
      redirect_to user_list_items_path(@user, @list)
    else
      flash[:error] = I18n.t('.not_updated', 
                             model: t('activerecord.models.item'))
      render action: 'edit'
    end  
  end

  def destroy
    Item.find(params[:id]).destroy
    flash[:success] = I18n.t('.destroyed', model: t('activerecord.models.item'))
    @list = List.find(params[:list_id])
    @user = User.find(params[:user_id])
    redirect_to user_list_items_path(@user, @list)
  end

  private

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
