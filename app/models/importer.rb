class Importer

  class Row

    attr_accessor :data, :attributes, :selected

    def initialize(data, attributes)
      @data = data
      @attributes = attributes.each_with_index.inject({}) do |hash, data| 
        hash[data[0].to_sym] = data[1] 
        hash 
      end
    end

    def method_missing(name, *args, &block)
      @data[@attributes[name]]
    end

  end  

  attr_accessor :data, :col_count, :header, :formats, :rows

  def initialize(data, options = {})
    set_column_count(options[:col_count]) || raise_column_count_missing
    process_data(data) || raise_data_missing
    set_header(options[:header])
    set_formats(options[:formats])
    set_rows
  end

  def row_count
    @rows.size
  end

  private

    def set_column_count(count)
      @col_count = count
    end

    def raise_column_count_missing
      raise "column count missing"
    end

    def process_data(data)
      return false if data.nil?
      @data = data.map { |line| line.chomp.split(";") }
    end

    def raise_data_missing
      raise "data missing"
    end

    def set_header(header)
      @header = if !header.nil? && header.size == @col_count
        header
      else
        ("1"..@col_count.to_s).to_a
      end
    end

    def set_formats(formats)
      @formats = if !formats.nil? && formats.size == @col_count
        formats
      else
        Array.new(@col_count, /.*/)
      end
    end

    def set_rows
      @rows = []
      @data.each do |d|
        if match(d)
          @rows << Importer::Row.new(d, @header)
        end
      end
    end

    def match(data)
      data.each_with_index do |c,i|
        return false unless c =~ @formats[i]
      end
      true
    end
end
