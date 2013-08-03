class StaticPagesController < ApplicationController
  skip_before_filter :authorize

  def home
    if params[:set_locale]
      redirect_to root_path(locale: params[:set_locale])
    else
      @news = News.last
      @event = Event.find_by_active(true)
    end
  end

  def help
  end

  def about
  end

  def contact
    @message = Message.new
  end

  def message
    @message = Message.new(params[:message])
    unless @message.valid?
      render 'contact'
    else
      UserMailer.user_request(@message).deliver
      redirect_to root_path, notice: I18n.t('.contact_success') 
    end
  end
end
