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
  end
end
