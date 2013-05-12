class StaticPagesController < ApplicationController
  skip_before_filter :authorize

  def home
  end

  def help
  end

  def about
  end

  def contact
  end
end
