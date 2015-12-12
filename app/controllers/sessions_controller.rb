class SessionsController < ApplicationController
  skip_before_filter :authorize

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email])
    if user and user.authenticate(params[:session][:password])
      sign_in user
      accept_terms_of_use or redirect_back_or user
    else
      flash.now[:error] = I18n.t('.invalid_email_password')
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
