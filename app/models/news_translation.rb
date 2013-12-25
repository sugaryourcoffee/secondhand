class NewsTranslation < ActiveRecord::Base
  belongs_to :news

  attr_accessible :title, :description, :language, :news_id

  validates :title, :description, :language, presence: true
end
