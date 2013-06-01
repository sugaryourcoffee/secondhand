class ItemsController < ApplicationController

  skip_before_filter :authorize, only: [:index, :new, :create]

  before_filter :correct_user

  def index
    @items = Item.where({ list_id: params[:list_id] }).all
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
      flash[:success] = "Item created!"
      redirect_to user_list_items_path(@user, @list)
    else
      flash[:error] = @item.errors.full_messages.join(" | ")
      render 'new'
    end 
  end

  private

  def correct_user
    user = User.find(params[:user_id])

    users_list = List.find(params[:list_id]).user_id == user.id
    
    unless users_list or current_user.admin?
      flash[:warning] = "List number not assigned"
      redirect_to(root_path)
    end
  end
end
