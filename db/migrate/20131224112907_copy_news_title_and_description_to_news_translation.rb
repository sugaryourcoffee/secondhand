class CopyNewsTitleAndDescriptionToNewsTranslation < ActiveRecord::Migration

  class NewsTranslation < ActiveRecord::Base
    attr_accessible :title, :description, :language, :news_id

    belongs_to :news
  end
  
  class News < ActiveRecord::Base
    has_many :news_translations
  end

  def up
    News.reset_column_information
    News.all.each do |news|
      news.news_translations.create!(title: news.title,
                                     description: news.description,
                                     language: 'de',
                                     news_id: news.id)
    end
  end

  def down
    News.reset_column_information
    News.all.each do |news|
      news.news_translations.delete_all
    end
    NewsTranslation.destroy_all
  end
end
