class StaticPagesController < ApplicationController
  skip_before_filter :authorize

  def home
    if params[:set_locale]
      redirect_to root_path(locale: params[:set_locale])
    else
      @news = News.last
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
