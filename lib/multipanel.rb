class Multipanel

  attr_accessor :cols, :panel, :chart, :scale, :charts, :counter

  def initialize(width = 400, chart_height = 200, count = 1, cols = 1)
    @cols    = cols
    @panel   = { width:  width, 
                 height: chart_height * (count.to_f / cols).ceil }
    @chart   = { width:  width / cols, height: chart_height }
    @scale   = { x: @chart[:width]/@panel[:width].to_f, 
                 y: @chart[:height]/@panel[:height].to_f }
    @charts  = []
    @counter = 0
    frame(@panel[:width], @panel[:height])
  end

  def to_svg
    svg = "<svg width=\"#{@panel[:width]}\" height=\"#{@panel[:height]}\"
            xmlns=\"http://www.w3.org/2000/svg\">
            <title>Multipanel</title>
            <desc>Showing multiple panels</desc>\n"

    svg << @charts.join("\n")
    svg << "</svg>"
  end

  def to_html(file = "multi.html")
    html = "<html>\n#{to_svg}\n</html>"

    File.open(file, "w") do |f|
      f.puts html
    end
    file
  end

  def to_file(file = "multi.svg")
    svg = "<?xml version=\"1.0\"?> 
           <!DOCTYPE sv PUBLIC \"-//W3C//DTD SVG 1.1//EN\" 
           \"http://www.w3.org/Graphics/SVG/SVG/1.1/DTD/svg11.dtd\">\n"

    File.open(file, "w") do |f|
      f.puts svg + to_svg
    end
    file
  end

  def add(chart)
    x_offset = (@counter % @cols) * @chart[:width]
    y_offset = @counter  / @cols  * @chart[:height]
    x_scale  = @scale[:x]
    y_scale  = @scale[:y]
    @counter += 1
    @charts << transform(counter, chart, x_offset, y_offset, x_scale, y_scale)
  end

  def clear
    @charts = []
    @counter = 0
  end

  def transform(id, chart, x, y, x_scale, y_scale)
    STDERR.puts "#{id}: #{x} | #{y} | #{x_scale} | #{y_scale}"
    "<symbol id=\"chart-#{id}\">
       #{chart}
     </symbol>
     <use xlink:href=\"#chart-#{id}\" transform=\"translate(#{x}, #{y})
          scale(#{x_scale}, #{y_scale})\"/>"
  end

  def frame(width, height)
    @charts << "<rect x=\"0\" y=\"0\" width=\"#{width}\" 
                  height=\"#{height}\" 
                  style=\"fill:none;stroke:green;stoke-width:1;stroke-opacity=0.5\"/>"
  end
end
