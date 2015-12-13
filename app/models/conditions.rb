class Conditions < ActiveRecord::Base
  has_many :terms_of_uses, dependent: :destroy

  validates :version, presence: true, 
                      allow_blank: false, 
                      uniqueness: { case_sensitive: false }

  def clone_with_associations
    clone = dup
    clone.version = "#{version} - #{Time.now.strftime('%F %H:%M:%S:%L')}"
    clone.save
    terms_of_uses.each do |terms_of_use|
      clone.terms_of_uses << terms_of_use.clone_with_associations(clone)
    end
    clone
  end

  def available_locales
    taken_locales = terms_of_uses.pluck(:locale)
    LANGUAGES.reject { |locale| taken_locales.include? locale[1] }
  end

  def next_available_locale
    (LANGUAGES.collect { |l| l[1] } - terms_of_uses.pluck(:locale)).first
  end
end
