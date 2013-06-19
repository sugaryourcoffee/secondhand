module ApplicationHelper

  def full_title(page_title)
    base_title = "Secondhand"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def selected_language
    unavailable = lambda { "Language" }
    LANGUAGES.detect(unavailable) { |l| l[1] == I18n.locale.to_s }[0]
  end

end
