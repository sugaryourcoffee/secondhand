class ItemsController < ApplicationController

  skip_before_filter :authorize, only: [:index]

  before_filter :correct_user

  def index
    @items = Item.where({ list_id: params[:list_id] }).all
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
