class Conditions < ActiveRecord::Base
  has_many :terms_of_uses, dependent: :destroy

  validates :version, presence: true, 
                      allow_blank: false, 
                      uniqueness: { case_sensitive: false }

  def clone_with_associations
    clone = dup
    clone.save
    terms_of_uses.each do |terms_of_use|
      clone.terms_of_uses << terms_of_use.clone_with_associations
    end
    clone
  end

end
