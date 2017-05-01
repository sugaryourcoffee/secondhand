class Boxplot < Chart

  # Creates an SVG file with boxplots. The boxpots' data is provided in an 
  # array of boxplots
  def to_svg(data)
    count       = data.count
    frequencies = data.map { |h| h[:outliers].max }
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
    x = @canvaz[:x0] - width
    data.map { |d| boxplot(x += width + space, d, width - space) }.join("\n")
  end

  def boxplot(x, data, width)
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
    box_height = (data[:q3] - data[:q1]) * @scales[:y]
    svg << rect(x, box_y, width, box_height)

    median_y = @canvaz[:y0] + @canvaz[:height] - data[:q2] * @scales[:y]
    svg << hline(x, median_y, width, { stroke: 'green' })
  end
end
