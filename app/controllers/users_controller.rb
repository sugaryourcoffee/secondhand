class UsersController < ApplicationController
  skip_before_filter :authorize, only: [:show, :new, :create, :edit, :update] 
  before_filter :signed_in_user, only: [:show, :edit, :update]
  before_filter :correct_user, only: [:show, :edit, :update]

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to Sugar Your Coffee!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_path
  end

  def register_list
    user = User.find(params[:id])
    list = List.find_by_registration_code(params[:registration_code])
    if list
      flash[:success] = "List registered"
    else
      flash[:warning] = "Registration code not valid"
    end
    redirect_to user
  end

  private
=begin
  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_path, notice: "Please sign in." unless signed_in?
    end
  end
=end
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user) or current_user.admin?
  end

end
