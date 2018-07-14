class UsersController < ApplicationController
  skip_before_filter :authorize, only: [:register_list, :deregister_list,
                                        :show, :new, :create, :edit, :update,
                                        :print_address_labels] 
  before_filter :signed_in_user, only: [:register_list, 
                                        :deregister_list, :show, :edit, :update]
  before_filter :correct_user, only: [:register_list, 
                                      :deregister_list, :show, :edit, :update]

  before_filter :accept_terms_of_use, only: :show

  def index
    @users = User.where(User.search_conditions(params))
                 .order(:last_name)
                 .paginate(page: params[:page])

  end

  def show
    @user = User.find(params[:id])
    @event = Event.find_by(active: true)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
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
    if @user.update_attributes(user_params)
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

  def deactivate
    user = User.find(params[:id])
    user.deactivate
    if user.save
      flash[:success] = I18n.t('.deactivated', 
                               model: t('activerecord.models.user'))
    else
      puts user.errors.messages
      flash[:error] = I18n.t('.deactivation_error',
                             model: t('activerecord.model.user'))
    end
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
    event = Event.find_by(active: true)
    registration_code = params[:registration_code]
    list = List.find_by(registration_code: registration_code, event_id: event) 
    if list
      if list.user_id
        flash[:error] = I18n.t('.taken', model: t('activerecord.models.list'))
      else
        list.user_id = user.id
        list.save
        UserMailer.list_registered(user, list).deliver
        flash[:success] = I18n.t('.registered', 
                                 model: t('activerecord.models.list'))
      end
    else
      flash[:warning] = I18n.t('.not_valid', 
                               model: t('activerecord.models.list'))
    end
    redirect_to user_path(user)
  end

  def deregister_list
    user = User.find(params[:id])
    list = List.find_by(id: params[:list_id], user_id: user.id) 
    unless list
      flash[:error] = I18n.t('.not_own_list')
    else
      list.user_id = nil
      list.container = nil
      list.sent_on = nil
      list.items.destroy_all
      if list.save
        UserMailer.list_deregistered(user, list).deliver
        flash[:success] = I18n.t('.deregistered',
                                 model: t('activerecord.models.list'))
      else
        flash[:error] = I18n.t('.deregistration_error',
                               model: t('activerecord.models.list'))
      end
    end
    redirect_to user_path(user)
  end

  def print_address_labels
    user = User.find(params[:id])
    respond_to do |format|
      format.pdf do
        send_data user.address_labels_as_pdf(count: 20,
                                             labels_per_page: 20,
                                             labels_per_row: 2), 
                                             content_type: Mime::PDF
      end
    end
  end

  private

    def user_params
      params.require(:user)
            .permit(:first_name, :last_name, 
                    :street, :zip_code, :town, :country, 
                    :email, :phone,
                    :news, :preferred_language,
                    :password_digest, :password, :password_confirmation,
                    :privacy_statement)
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user) or current_user.admin?
    end
end
