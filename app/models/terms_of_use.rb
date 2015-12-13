class TermsOfUse < ActiveRecord::Base
  belongs_to :conditions
  has_many :pages, -> { order(:number) }, dependent: :destroy

  validates :locale, presence: true, 
                     allow_blank: false, 
                     uniqueness: { scope: :conditions }

  def clone_with_associations(parent = conditions)
    clone = dup
    if parent.id == conditions.id
      clone.locale = conditions.next_available_locale 
    else
      clone.conditions_id = parent.id
    end
    clone.save
    pages.each do |page|
      clone.pages << page.dup
    end
    clone
  end

  def next_free
    all_numbers = pages.pluck(:number)
    ([*1..(all_numbers.size+1)] - all_numbers).first
  end

  def next_page(page, direction)
    page_numbers = pages.pluck(:number)
    pos = page_numbers.index(page)
    next_page = page_numbers.at(pos + direction)
    next_page.nil? ? page_numbers.min : next_page
  end

  def last_page
    pages.pluck(:number).max
  end

  def first_page
    pages.pluck(:number).min
  end

end
