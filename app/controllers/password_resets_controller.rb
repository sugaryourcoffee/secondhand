class PasswordResetsController < ApplicationController
  skip_before_filter :authorize

  def create
    user = User.find_by(email: params[:email]) # find_by_email(params[:email])
    if user
      user.send_password_reset
      redirect_to root_url, 
                  notice: I18n.t('.password_reset_instructions')
    else
      redirect_to root_url,
                  notice: I18n.t('.email_address_not_valid')
    end
  end

  def edit
    @user = User.find_by!(password_reset_token: params[:id]) #find_by_password_reset_token!(params[:id])
  end

  def update
    @user = User.find_by!(password_reset_token: params[:id]) #find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_reset_path, 
                  alert: I18n.t('.password_reset_expired')
    elsif @user.update_attributes(user_params) # params[:user])
      redirect_to root_url, notice: I18n.t('.password_reset_success')
    else
      render :edit
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
end
