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

  def list_statistics_for(event = @event)
    statistics = ListStatistics.new(event)
    if block_given?
      yield statistics
    else
      statistics
    end
  end

  def selling_statistics_for(event = @event)
    statistics = SellingStatistics.new(event)
    if block_given?
      yield statistics
    else
      statistics
    end
  end

end
