class NewsController < ApplicationController

  def index
    @all_news = News.all
  end

  def show
    @news = News.find(params[:id])
  end

  def new
    @news = News.new
  end

  def edit
    @news = News.find(params[:id])
  end

  def update
    @news = News.find(params[:id])
    
    if @news.update_attributes(params[:news])
      flash[:success] = "News updated"
      redirect_to @news
    else
      render 'edit'
    end
  end

  def create
    @news = News.new(params[:news])
    if @news.save
      flash[:success] = "Successfully created new news entry!"
      redirect_to @news
    else
      render 'new'
    end
  end

  def destroy
    News.find(params[:id]).destroy
    flash[:success] = "News destroyed."
    redirect_to news_index_path
  end

end
