module ApplicationHelper

  def logo
    "Secondhand #{Rails.env.production? ? '' : Rails.env.upcase}"
  end

  def local_date_and_time(date_and_time)
    date_and_time.localtime.strftime("%Y-%m-%d - %H:%M:%S")
  end

  def full_title(page_title)
    base_title = "Secondhand"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def sort_direction_for(column)
    (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
  end

  def selected_language
    unavailable = lambda { "Language" }
    LANGUAGES.detect(unavailable) { |l| l[1] == I18n.locale.to_s }[0]
  end

  def active_event
    Event.find_by(active: true) # find_by_active(true)
  end

  def back_or_path(default)
    request.referer.nil? ? default : :back
  end

  def list_statistics_for(event = @event)
    statistics = ListStatistics.new(event)
    if block_given?
      yield statistics
    else
      statistics
    end
  end

  def event_statistics
    statistics = Statistics.new
    if block_given?
      yield statistics
    else
      statistics
    end
  end

  def event_multi_panel(width = 940, chart_height = 300, charts_per_row = 2)
    statistics = Statistics.new
    titles, histograms = statistics.event_list_revenues_histogram
    histogram_count = histograms.count
    multipanel = Multipanel.new(width, 
                                chart_height, 
                                histogram_count, 
                                charts_per_row) 
    histogram = Histogram.new(multipanel.panel[:width], 
                              multipanel.panel[:height])
    histograms.each_with_index do |h,i| 
      multipanel.add(histogram.content(h, { title: titles[i], 
                                            x_label: :number} ))
    end

    multipanel.to_file("tmp/multi.svg")
  end

  def event_graphic_statistics(width = 940, height = 600)
    statistics = Statistics.new
    histogram  = Histogram.new(width, height)
    boxplot    = Boxplot.new(width, height)
    if block_given?
      yield statistics, histogram, boxplot
    else
      [statistics, histogram, boxplot]
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

  def reversal_statistics_for(event = @event)
    statistics = ReversalStatistics.new(event)
    if block_given?
      yield statistics
    else
      statistics
    end
  end

  def counter_statistics_for(event = @event)
    selling_statistics = SellingStatistics.new(event)
    reversal_statistics = ReversalStatistics.new(event)
    if block_given?
      yield selling_statistics, reversal_statistics
    else
      [selling_statistics, reversal_statistics]
    end
  end
end
