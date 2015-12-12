class Page < ActiveRecord::Base
  belongs_to :terms_of_use

  validates :number, :title, :content, presence: true, allow_blank: false
  validates :number, uniqueness: { scope: :terms_of_use }
end
