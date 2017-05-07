class Histogram

  def initialize(width = 400, height = 400)
    @panel = { width:  width, 
               height: height }

    @canvas = { x0:     0.1 * width, 
                y0:     0.1 * height,
                width:  0.8 * width, 
                height: 0.8 * height }
    
    @scales = { x: 1,
                y: 1 }

    @y_scale = { base: 1,
                 exp:  1 }
  end

  def content(hist, options = {})
    count       = hist.count
    frequencies = hist.map { |h| h["frequency"] }
    width       = @canvas[:width] / count
    max         = frequencies.max
    c           = canvas(max, count, width)
    b           = bars(hist, width, options)

    svg = "<rect x=\"0\" y=\"0\" width=\"#{@panel[:width]}\" 
             height=\"#{@panel[:height]}\" 
             style=\"fill:none;stroke:green;stoke-width:1\"/>"
    if options[:title]
      svg << text(@panel[:width] / 2, 25, options[:title], "middle")
    end
    svg << c
    svg << b
  end

  def to_svg(hist)
    svg = "<svg width=\"#{@panel[:width]}\" height=\"#{@panel[:height]}\"
            xmlns=\"http://www.w3.org/2000/svg\">"
    svg << content(hist) 
    svg << "</svg>"
  end

  def to_html(hist, file = "hist.html")
    html = "<html>#{to_svg(hist)}</html>"

    File.open(file, "w") do |f|
      f.puts html
    end
    file
  end

  def to_file(hist, file = "hist.svg")
    svg = "<?xml version=\"1.0\"?> 
           <!DOCTYPE sv PUBLIC \"-//W3C//DTD SVG 1.1//EN\" 
           \"http://www.w3.org/Graphics/SVG/SVG/1.1/DTD/svg11.dtd\">"

    File.open(file, "w") do |f|
      f.puts svg + to_svg(hist)
    end
    file
  end

  def canvas(max, count, width=40)
    width_scale  = @canvas[:width] / (count * width)
    height_scale = @canvas[:height] / max 
    @scales      = { x: width_scale, y: height_scale }
    @y_scale     = number_format(max, 3)
    increment    = steps(max)
    ticks        = increment * height_scale
    scale        = -increment

    area = []
    area << text(@canvas[:x0] - 20, 
                 @canvas[:y0] - 20, 
                 "#{@y_scale[:base]}
                  <tspan baseline-shift=\"super\" font-size=\"10\">
                  #{@y_scale[:exp]}</tspan>") if @y_scale[:base] > 1

    @canvas[:height].step(0, -ticks) do |s|
      area << text(@canvas[:x0] - 20, 
                   (@canvas[:y0]+s).to_i, 
                    format_number(scale += increment, increment, @y_scale))
      area << line(s.to_i, @canvas)
    end 

    area.join("\n")
  end

  def bars(hist, width=40, options = {})
    x = @canvas[:x0]
    y = @canvas[:y0] + @canvas[:height]

    width *= @scales[:x]

    x_label = lambda do |x, h, i|
      if options[:x_label] == :number
        label = h.scan(/\d+\.?\d*$/)
        category(x + width, y + 20, '%.1f' % label)
      else
        category(x + width/2, y + 20, roman(i+1))
      end
    end

    bars = []

    hist.each_with_index do |h, i|
      freq = h["frequency"] * @scales[:y]

      bars << text(x + width/2, 
                   y - freq - 10, h["frequency"], "middle", "baseline")
      bars << bar(x, y - freq, width, freq)
      bars << x_label.call(x, h["sum_range"], i)

      x += width
    end  

    bars.join("\n")
  end

  def text(x, y, text, anchor = "end", alignment = "middle")
    "<text x=\"#{x}\" y=\"#{y}\" fill=\"red\" 
     text-anchor=\"#{anchor}\" 
     alignment-baseline=\"#{alignment}\">#{text}</text>"
  end

  def legend
  end

  def bar(x, y, width, height)
    "<rect x=\"#{x}\" y=\"#{y}\" width=\"#{width}\" height=\"#{height}\" 
      style=\"fill:rgb(0,0,255);stroke-width:1;stroke:rgb(255,255,255)\" />"  
  end

  def category(x, y, cat)
    "<text x=\"#{x}\" y=\"#{y}\" fill=\"red\" text-anchor=\"middle\">
       #{cat}
     </text>"
  end

  def line(step, svg)
    x1 = svg[:x0] - 5
    y  = svg[:y0] + step
    x2 = svg[:x0] + svg[:width] + 5

    "<line x1=\"#{x1}\" y1=\"#{y}\" x2=\"#{x2}\" y2=\"#{y}\" 
     style=\"stroke:rgb(255,0,0)\" />"
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
    if number / 10 ** digits > 0
      exp = Math.log10(number).floor - 2
      { divisor: (10 ** exp), base: 10, exp: exp }
    else
      { divisor: 1, base: 1, exp: 1 }
    end
  end

  def format_number(number, increment, scale)
    y = (number / scale[:divisor])
    increment == 0.5 ? y.to_f : y.to_i
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
