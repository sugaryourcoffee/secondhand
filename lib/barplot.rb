class Barplot < Chart

  # Draws a barplot based on the provided data. data is a hash with following
  # structure
  #
  # data = { "categories"=>['A', 'B', 'C'], "values"=>[10, 20, 30] }
  #
  # Additional parameters are
  #
  # title  - of the barplot
  # xlabel - label of the x axes
  # ylabel - label of the y axes
  # width  - of a bar
  # space  - between bars
  def to_svg(data, options={})
    count       = data["values"].count
    max         = data["values"].max
    width       = (@canvaz[:width] - count * (options["space"] || 0)) / count
    c           = canvas(max, count, width, options)
    b           = barplot(data, width, options)

    svg =  "<svg width=\"#{@panel[:width]}\" height=\"#{@panel[:height]}\"
              xmlns=\"http://www.w3.org/2000/svg\">"
    svg << "<rect x=\"0\" y=\"0\" width=\"#{@panel[:width]}\" 
              height=\"#{@panel[:height]}\" 
              style=\"fill:none;stroke:green;stoke-width:1\"/>"
              
    if options["title"]
      svg << text(@panel[:width] / 2, 25, options["title"], 
                  { text_anchor: "middle" })
    end
    svg << c
    svg << b
  end

  def barplot(data, width=40, options = {})
    x = @canvaz[:x0]
    y = @canvaz[:y0] + @canvaz[:height]

    width = @scales[:x] * (width - options["space"])

    x_label = lambda do |x, i|
      if data["categories"]
        label = data["categories"][i]
      else
        label = roman(i+1)
      end
      text(x + width/2, y + 20, label)
    end

    bars = []

    data["values"].each_with_index do |v, i|
      freq = v * @scales[:y]

      bars << text(x + width/2, 
                   y - freq - 10, v, { text_anchor: "middle", 
                                       alignment_baseline: "baseline" })
      bars << rect(x, y - freq, width, freq, { fill: "blue",
                                               fill_opacity: 0.9 })
      bars << x_label.call(x, i)

      x += width + options["space"]
    end  

    bars.join("\n")
  end

end
