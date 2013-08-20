class ApplicationController < ActionController::Base
  before_filter :set_i18n_locale_from_params

  before_filter :authorize

  protect_from_forgery
  include SessionsHelper

  protected

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_path, notice: I18n.t('.sign_in') unless signed_in?
    end
  end

  def authorize
    if current_user.nil? 
      store_location
      redirect_to signin_path, notice: I18n.t('.sign_in') 
    elsif not current_user.admin?
      redirect_to root_path, 
                  notice: I18n.t('.admin_privileges')
    end
  end

  def set_i18n_locale_from_params
    if params[:locale]
      if I18n.available_locales.include?(params[:locale].to_sym)
        I18n.locale = params[:locale]
      else
        flash.now[:notice] = "#{params[:locale]} translation not available"
        logger.error flash.now[:notice]
      end
    end
  end

  def default_url_options
    { locale: I18n.locale }
  end

end
