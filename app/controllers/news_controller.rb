class NewsController < ApplicationController

  def index
    @all_news = News.all
  end

  def show
    @news = News.find(params[:id])
  end

  def new
    @news = News.new(issue: next_issue)
  end

  def edit
    @news = News.find(params[:id])
  end

  def update
    @news = News.find(params[:id])
    
    if @news.update_attributes(params[:news])
      flash[:success] = I18n.t('.updated', model: t('activerecord.models.news'))
      redirect_to @news
    else
      render 'edit'
    end
  end

  def create
    @news = News.new(params[:news])
    if @news.save
      flash[:success] = I18n.t('.created', model: t('activerecord.models.news'))
      redirect_to @news
    else
      render 'new'
    end
  end

  def destroy
    News.find(params[:id]).destroy
    flash[:success] = I18n.t('.destroyed', model: t('activerecord.models.news'))
    redirect_to news_index_path
  end

  private

    def next_issue
      start_time = Time.new(Time.now.year-1, 12, 31)
      end_time = Time.new(Time.now.year+1, 1, 1) 
      issue = "#{News.where({ updated_at: start_time...end_time }).count+1}"+
              "/#{Time.now.year}"
    end
end
