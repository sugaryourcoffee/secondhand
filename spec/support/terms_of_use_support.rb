def create_pages_for(terms_of_use, count)
  1.upto(count) do |page|
    terms_of_use.pages.create!(number: page, 
                               title: "Page #{page}",
                               content: "This is page number #{page}")
  end
end
