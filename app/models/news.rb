class News < ActiveRecord::Base

  belongs_to :user

  default_scope { order('updated_at desc') }

  has_many :news_translations, dependent: :destroy

  accepts_nested_attributes_for :news_translations

  validates :issue, :user, presence: true

  before_update :send_newsletter

  def author
    user.active? ? "#{user.first_name} #{user.last_name}" : "Anonymous"
  end

  def send_pending?
    released and not sent_on
  end

  def news_translation(locale = I18n.locale)
    news_translations.find_by(language: locale) # find_by_language(locale)
  end

  def with_translations
    languages = news_translations.map { |translation| translation.language }
    available_languages = LANGUAGES.map { |name, code| code }

    (available_languages - languages).each do |language|
      news_translations.build(language: language)
    end

    self
  end

  private

    def send_newsletter
      if sent_on_changed?
        LANGUAGES.each do |name, code|
          Newsletter.publish(self.news_translation(code), 
                             User.subscribers(code)).deliver_now
        end
      else
        self.sent_on = nil
      end
    end

end
