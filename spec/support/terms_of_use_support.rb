def create_pages_for(condition, count)
  condition.terms_of_uses.create!(locale: "en")

  1.upto(count) do |page|
    condition.terms_of_uses.first.pages.create!(number: page, 
                                        title: "Page #{page}",
                                        content: "This is page number #{page}")
  end
end

def create_pages_for_terms_of_use(terms_of_use, count)
  1.upto(count) do |page|
    terms_of_use.pages.create!(number: page, 
                               title: "Page #{page}",
                               content: "This is page number #{page}")
  end
end
