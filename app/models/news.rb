class News < ActiveRecord::Base
  attr_accessible :description, :title

  validates :description, :title, presence: true
end
