class News < ActiveRecord::Base
  attr_accessible :issue, :promote_to_frontpage, :released, :user_id, :news_translations_attributes

  belongs_to :user

  has_many :news_translations

  accepts_nested_attributes_for :news_translations

  validates :issue, :promote_to_frontpage, :released, :user, presence: true

  def author
    "#{user.first_name} #{user.last_name}"
  end

  def news_translation(locale = I18n.locale)
    news_translations.find_by_language(locale)
  end

  def with_translations
    LANGUAGES.each do |name, code|
      news_translations.build(language: code)
    end
    self
  end
end
