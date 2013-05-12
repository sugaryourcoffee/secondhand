class ApplicationController < ActionController::Base
  before_filter :authorize

  protect_from_forgery
  include SessionsHelper

  protected

  def authorize
    if not current_user.nil? and not current_user.admin?
      redirect_to root_path, 
                  notice: "You need admin privieges to access this site. "+
                          "Please log out and login in as admin user"
    end
  end
end
