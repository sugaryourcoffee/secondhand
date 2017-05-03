class Chart

  attr_accessor :panel, :canvaz, :scales, :y_scale

  def initialize(width = 400, height = 400)
    @panel = { width:  width, 
               height: height }

    @canvaz = { x0:     0.1 * width, 
                y0:     0.1 * height,
                width:  0.8 * width, 
                height: 0.8 * height }
    
    @scales = { x: 1,
                y: 1 }

    @y_scale = { divisor: 1,
                 base: 1,
                 exp:  1 }
  end

  def to_html(data, file = "chart.html")
    html = "<html>#{to_svg(data)}</html>"

    File.open(file, "w") do |f|
      f.puts html
    end
    file
  end

  def to_file(data, file = "chart.svg")
    svg = "<?xml version=\"1.0\"?> 
           <!DOCTYPE sv PUBLIC \"-//W3C//DTD SVG 1.1//EN\" 
           \"http://www.w3.org/Graphics/SVG/SVG/1.1/DTD/svg11.dtd\">"

    File.open(file, "w") do |f|
      f.puts svg + to_svg(hist)
    end
    file
  end

  # Creates a canvas where the chart is drawn on.
  #
  # max: maximum value
  # count: number of elements drawn (bars, boxes, ...)
  # width: width of the element
  # options: 
  # * ruler: if true draws horizontally are ruler over the canvas else draws
  #          ticks at the y axes
  # * frame: if true draws a frame around the canvas
  def canvas(max, count, width=40, options = {})
    @scales      = { x: @canvaz[:width]  / (count * width), 
                     y: @canvaz[:height] / max }
    @y_scale     = number_format(max, 4)
    increment    = steps(max)
    ticks        = increment * @scales[:y]
    scale        = -increment
    ruler_width  = options[:ticks] ? 5 : @canvaz[:width] + 5

    area = []
    area << text(@canvaz[:x0] - 15, 
                 @canvaz[:y0] - 15, 
                 "#{@y_scale[:base]} 
                  <tspan baseline-shift=\"super\" font-size=\"10\">
                  #{@y_scale[:exp]}</tspan>",
                  { text_anchor: "end" }) if @y_scale[:base] > 1

    area << rect(@canvaz[:x0], @canvaz[:y0], 
                 @canvaz[:width], @canvaz[:height],
                 { stroke_opacity: 0.1 }) if options[:frame]

    @canvaz[:height].step(0, -ticks) do |s|
      area << text(@canvaz[:x0] - 15, 
                   (@canvaz[:y0]+s).to_i, 
                    format_number(scale += increment, @y_scale))
      area << hline(@canvaz[:x0] - 5, (@canvaz[:y0] + s).to_i, ruler_width)
    end 

    area.join("\n")
  end

  # Default SVG text options
  TEXT_OPTIONS = { fill: 'red',
                   text_anchor: 'end',
                   alignment_baseline: 'middle' }

  # Draws a text starting at position (x,y) 
  #
  # x: x position of the label
  # y: y position of the label
  # text: text to be added
  def text(x, y, text, options={})
    options = TEXT_OPTIONS.merge(options)

    "<text x=\"#{x}\" y=\"#{y}\" 
           fill=\"#{options[:fill]}\" 
           text-anchor=\"#{options[:text_anchor]}\" 
           alignment-baseline=\"#{options[:alignment_baseline]}\">
       #{text}
     </text>"
  end

  # Default SVG line options
  LINE_OPTIONS = { stroke: 'blue',
                   stroke_width: 1,
                   stroke_linecap: 'butt',
                   stroke_opacity: '0.9',
                   dasharray: '0' }

  # Draws a horizontal line starting at position (x,y) 
  #
  # x: x position of the ruler
  # y: y position of the ruler
  def hline(x, y, width, options = {})
    options = LINE_OPTIONS.merge(options)

    "<line x1=\"#{x}\" y1=\"#{y}\" x2=\"#{x+width}\" y2=\"#{y}\" 
           style=\"stroke:#{options[:stroke]};
                   stroke-width:#{options[:stroke_width]};
                   stroke-linecap:#{options[:stroke_linecap]};
                   stroke-opacity:#{options[:stroke_opacity]};
                   stroke-dasharray:#{options[:dasharray]}\"/>"
  end

  # Draws a vertical line starting at position (x,y) 
  #
  # x: x position of the ruler
  # y: y position of the ruler
  def vline(x, y, height, options = {})
    options = LINE_OPTIONS.merge(options)

    "<line x1=\"#{x}\" y1=\"#{y}\" x2=\"#{x}\" y2=\"#{y+height}\" 
           style=\"stroke:#{options[:stroke]};
                   stroke-width:#{options[:stroke_width]};
                   stroke-linecap:#{options[:stroke_linecap]};
                   stroke-opacity:#{options[:stroke_opacity]};
                   stroke-dasharray:#{options[:dasharray]}\"/>"
  end

  # Default SVG rect options
  RECT_OPTIONS = { fill: 'white',
                   fill_opacity: 0.1,
                   stroke: 'blue',
                   stroke_width: 1,
                   stroke_opacity: 0.9,
                   dasharray: '0' }

  # Draws a line starting at position (x,y) 
  #
  # x: x position of the ruler
  # y: y position of the ruler
  def rect(x, y, width, height, options = {})
    options = RECT_OPTIONS.merge(options)

    "<rect x=\"#{x}\" y=\"#{y}\" width=\"#{width}\" height=\"#{height}\" 
           style=\"fill:#{options[:fill]};stroke:#{options[:stroke]};
                   stroke-width:#{options[:stroke_width]};
                   fill-opacity:#{options[:fill_opacity]};
                   stroke-opacity:#{options[:stroke_opacity]};
                   stroke-dasharray:#{options[:dasharray]}\"/>"
  end

  # Default SVG circle options
  CIRCLE_OPTIONS = { fill: 'blue',
                     fill_opacity: 0.1,
                     stroke: 'black',
                     stroke_width: 1,
                     stroke_opacity: 0.9,
                     dasharray: '0' }

  # Draws a circle starting at center position (cx,cy) 
  #
  # cx: center x position of the circle
  # cy: center y position of the circle
  def circle(cx, cy, r, options = {})
    options = CIRCLE_OPTIONS.merge(options)

    "<circle cx=\"#{cx}\" cy=\"#{cy}\" r=\"#{r}\"
           style=\"fill:#{options[:fill]};stroke:#{options[:stroke]};
                   stroke-width:#{options[:stroke_width]};
                   fill-opacity:#{options[:fill_opacity]};
                   stroke-opacity:#{options[:stroke_opacity]};
                   stroke-dasharray:#{options[:dasharray]}\"/>"
  end

  # Numbers on the y-axes are dependent on the maximum value. 
  #
  # max | steps |
  # 5   |   0.5 |
  # 9   |    1  |
  # 49  |    5  |
  # 99  |   10  |
  # 490 |   50  |
  # 999 |  100  |
  def steps(value)
    factor = 10**(Math.log10(value).floor - 1)
    case 
    when value < factor * 10
      factor
    when value < 5 * factor * 10
      5 * factor
    else
      10 * factor
    end
  end

  def number_format(number, digits)
    if number.floor / 10 ** digits > 0
      exp = Math.log10(number).floor - 2
      { divisor: (10 ** exp), base: 10, exp: exp }
    else
      { divisor: 1, base: 1, exp: 1 }
    end
  end

  def format_number(number, scale)
    y = (number / scale[:divisor]).to_i
  end

  # Roman numerals used for conversion. The notation from 5000 upwards the 
  # letters have an overbar. In the comments within the @romans hash the letters
  # with overbars are indicated by a following dot '.'
  ROMANS = {       1 => "I", 
                   4 => "IV",
                   5 => "V", 
                   9 => "IX",
                  10 => "X", 
                  40 => "XL", 
                  50 => "L", 
                  90 => "XC",
                 100 => "C", 
                 400 => "CD",
                 500 => "D", 
                 900 => "CM",
                1000 => "M",
                4000 => "\u004d\u0056\u0305",        # MV.
                5000 => "\u0056\u0305",              # V.
                9000 => "\u004d\u0058\u0305",        # MX.
               10000 => "\u0058\u0305",              # X.
               40000 => "\u0058\u0305\u004c\u0305",  # X.L.
               50000 => "\u004c\u0305",              # L.
               90000 => "\u0058\u0305\u0043\u0305",  # X.C.
              100000 => "\u0043\u0305",              # C.
              400000 => "\u0043\u0305\u0044\u0305",  # C.D.
              500000 => "\u0044\u0305",              # D.
              900000 => "\u0043\u0305\u004d\u0305",  # C.M.
             1000000 => "\u004d\u0305" }             # M.

  # Decimal to Roman converter. Displays values upto 3,999,999 in the roman
  # notation. From 4,000,000 it uses the million symbol dependent on the count 
  # of millions.         ____
  # Example: 5,000,000 = MMMM
  def roman(decimal)
    bases = ROMANS.keys
    roman = ""
    base = bases.pop
    while base > 1 and decimal > 0 do
      y = Math.log(decimal, base).floor 
      if y > 0
        roman << ROMANS[base] * y
        decimal -= base ** y
      else
        base = bases.pop
      end
    end
    roman << ROMANS[base] * decimal
  end

end
