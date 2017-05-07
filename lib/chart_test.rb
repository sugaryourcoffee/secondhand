require_relative 'statistics'
require_relative 'histogram'
require_relative 'multipanel'

class ChartTest

  attr_accessor :vectors, :histograms

  def initialize(vectors = [[1,2,3,3,5,9,15,20,25,27,30],[3,8,10,25,30,35], [10,18,20,30,45]])
    @vectors = vectors
    @statistics = Statistics.new
    @histograms = create_histogram_data(vectors)
    @multipanel = Multipanel.new(940,300,3,2)
    @histogram = Histogram.new(@multipanel.panel[:width], 
                               @multipanel.panel[:height])
  end

  def create_histogram_data(vectors, range = 10)
    h = vectors.map {|v| @statistics.histogram(v,range) }
    h.map { |h| h.map { |v| v.values }}.map {|v| v.flatten}
  end

  def run
    @histograms.each_with_index do |h,i| 
      @multipanel.add(@histogram.content(h, 
                                         { title: @titles[i], 
                                           x_label: :number} ))
    end
    @multipanel.to_html
    @multipanel.clear
  end

  def run2(range = nil)
    e = @statistics.event_list_revenues
    v = e.map { |k,v| v["values"] }
    @titles = e.map { |k,v| v["title"] }
    @histograms = create_histogram_data(v, range)
    run
  end

  def run3(data)
    @titles = data[0]
    @histograms = data[1]
    run
  end
end
