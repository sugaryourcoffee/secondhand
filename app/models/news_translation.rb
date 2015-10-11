class NewsTranslation < ActiveRecord::Base
  belongs_to :news

  validates :title, :description, :language, presence: true

  after_save :update_news

  private

    def update_news
      news.update_attribute(:updated_at, Time.now)
    end
end
