class Boxplot < Chart

  # Creates an SVG file with boxplots. The boxpots' data is provided in an 
  # array of boxplots data. The boxplot data can be created with quartile
  #
  # b = Boxplot.new
  # data = []
  # data << b.quartile([1,2,3,4,4,5,10,12,15,21,40,41])
  # => {:count=>12, :q2=>7.5, :q1=>3, :q3=>10, :iqr=>15:,
  #     :outliers=>[41], :min=>1, :max=>40}
  # b.to_svg(data)
  def to_svg(data, options = {})
    count       = data.count
    frequencies = data.map { |h| h[:outliers].max || h[:max] }
    space       = 5
    width       = (@canvaz[:width] - count * space) / count
    max         = frequencies.max
    c           = canvas(max, count, width, { frame: true, ticks: true })
    b           = boxplots(data, width, space)

    svg = "<svg width=\"#{@panel[:width]}\" height=\"#{@panel[:height]}\"
            xmlns=\"http://www.w3.org/2000/svg\">"
    svg << "<rect x=\"0\" y=\"0\" width=\"#{@panel[:width]}\" 
                  height=\"#{@panel[:height]}\" 
                  style=\"fill:none;stroke:green;stoke-width:1\"/>"
    svg << c
    svg << b
    svg << "</svg>"
  end

  def boxplots(data, width, space)
    i = 0
    x = @canvaz[:x0] - width
    data.map { |d| boxplot(i += 1, 
                           x += width + space, 
                           d, 
                           width - space) }.join("\n")
  end

  def boxplot(i, x, data, width)
    svg = []

    whisker_width  = width/2
    whisker_x      = x + whisker_width/2
    whisker_line_x = x + whisker_width
    dist_min_q1    = (data[:q1] - data[:min]) * @scales[:y]
    q1_y           = @canvaz[:y0] + @canvaz[:height] - data[:q1] * @scales[:y] 
    dist_q3_max    = (data[:max] - data[:q3]) * @scales[:y]

    data[:outliers].each do |o|
      y = @canvaz[:y0] + @canvaz[:height] - o * @scales[:y]
      svg << circle(whisker_line_x, y, 3)
    end

    whisker_y_min = @canvaz[:y0] + @canvaz[:height] - data[:min] * @scales[:y]
    svg << hline(whisker_x, whisker_y_min, whisker_width)

    svg << vline(whisker_line_x, q1_y, dist_min_q1, { dasharray: "5,5"})

    whisker_y_max = @canvaz[:y0] + @canvaz[:height] - data[:max] * @scales[:y]
    svg << hline(whisker_x, whisker_y_max, whisker_width)

    svg << vline(whisker_line_x, whisker_y_max, dist_q3_max, 
                 { dasharray: "5,5"})

    box_y = @canvaz[:y0] + @canvaz[:height] - data[:q3] * @scales[:y]
    box_height = data[:iqr] * @scales[:y]
    svg << rect(x, box_y, width, box_height)

    median_y = @canvaz[:y0] + @canvaz[:height] - data[:q2] * @scales[:y]
    svg << hline(x, median_y, width, { stroke: 'green' })

    svg << text(whisker_line_x, @canvaz[:y0] + @canvaz[:height] + 20, roman(i),
                { text_anchor: 'middle' })
  end
  
  # Calculates quartiles and expects a sorted array. This can be used together
  # with list_revenues
  #
  # stat = Boxplot.new
  # stat.quartile([1,2,3,4,4,4,10,10,11)
  #
  # => {:count=>11, outliers: [ 1, 2, 11], :min=>1, :max=>1033.0, 
  #     :q2=>12.0, :q1=>2.5, :q3=>556.5}
  def quartile(vector)
    count = vector.count

    result = { count: count, q2: median(vector) }
     
    if count/4 == count/4.0
       result[:q1] = (vector[count/4  -1] + vector[count/4  ])/2
       result[:q3] = (vector[count/4*3-1] + vector[count/4*3])/2
    else
       result[:q1] = vector[(count/4.0  ).floor]
       result[:q3] = vector[(count/4.0*3).floor]
    end

    result[:iqr] = result[:q3] - result[:q1]

    result[:outliers] = vector.select do |v| 
                                        v > result[:q3] + 1.5 * result[:iqr] || 
                                        v < result[:q1] - 1.5 * result[:iqr]
                                      end

    result[:min] = (vector - result[:outliers]).min
    result[:max] = (vector - result[:outliers]).max

    result
  end

  def median(vector)
    count = vector.count
    
    if count.odd?
      vector[count/2]
    else
      (vector[count/2 - 1] + vector[count/2])/2.0
    end
  end

end
