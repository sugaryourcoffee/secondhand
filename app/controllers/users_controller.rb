class UsersController < ApplicationController
  skip_before_filter :authorize, only: [:register_list,
                                        :show, :new, :create, :edit, :update] 
  before_filter :signed_in_user, only: [:register_list, :show, :edit, :update]
  before_filter :correct_user, only: [:register_list, :show, :edit, :update]

  def index
    @users = User.paginate(page: params[:page], 
                           conditions: User.search_conditions(params[:search]))
  end

  def show
    @user = User.find(params[:id])
    @event = Event.find_by_active(true)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      UserMailer.registered(@user).deliver
      flash[:success] = I18n.t('.welcome')
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = I18n.t('.updated',
                               model: t('activerecord.models.user'))
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = I18n.t('.destroyed', model: t('activerecord.models.user'))
    redirect_to users_path
  end

  def who_registered
    @users = User.all
    respond_to do |format|
      format.atom
    end
  end

  def register_list
    user = User.find(params[:id])
    event = Event.find_by_active(true)
    registration_code = params[:registration_code]
    list = List.find_by_registration_code_and_event_id(registration_code, 
                                                       event)
    if list
      if list.user_id
        flash[:error] = I18n.t('.taken', model: t('activerecord.models.list'))
      else
        list.user_id = user.id
        list.save
        flash[:success] = I18n.t('.registered', model: t('activerecord.models.list'))
      end
    else
      flash[:warning] = I18n.t('.not_valid', model: t('activerecord.models.list'))
    end
    redirect_to user_path(user)
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
