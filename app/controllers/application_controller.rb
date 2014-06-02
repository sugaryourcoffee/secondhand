class ApplicationController < ActionController::Base
  before_filter :set_i18n_locale_from_params

  before_filter :authorize

  protect_from_forgery
  include SessionsHelper

  private

    def current_cart
      Cart.find(session[:cart_id])
    rescue ActiveRecord::RecordNotFound
      cart = Cart.create
      session[:cart_id] = cart.id
      cart
    end

    def current_reversal_cart
      Cart.find(session[:reversal_cart_id])
    rescue ActiveRecord::RecordNotFound
      reversal_cart = Cart.create(cart_type: 'REDEMPTION')
      session[:reversal_cart_id] = reversal_cart.id
      reversal_cart
    end

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
