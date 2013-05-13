class ApplicationController < ActionController::Base
  before_filter :authorize

  protect_from_forgery
  include SessionsHelper

  protected

  def authorize
    if current_user.nil? 
      store_location
      redirect_to signin_path, notice: "Please sign in"
    elsif not current_user.admin?
      redirect_to root_path, 
                  notice: "You need admin privieges to access this site."
    end
  end
end
