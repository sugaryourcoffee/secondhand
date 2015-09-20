module SellingsExporter

  include ActionView::Helpers::NumberHelper
  include ItemsHelper

  def to_pdf(transaction = "Verkauf")

    header_left   = event.title
    header_center = "www.boerse-burgthann.de"
    header_right  = "#{transaction} #{id}"

    footer_left   = updated_at.strftime("%Y-%m-%d / %H:%M")
    footer_center = event.information || "mail@boerse-burgthann.de"

    pdf = Prawn::Document.new(page_size: "A4")

    pdf.move_down 25

    items_list = (line_items.sort_by { 
      |line_item| list_item_number_for(line_item.item) }).map do |line_item|
      [list_item_number_for(line_item.item),
       cut_to_fit(pdf, 389, line_item.description), 
       cut_to_fit(pdf, 71, line_item.size), 
       transaction_number_format(transaction, line_item.price)]
    end

    # DEBUGGING START
    File.open("tmp/print_log", "a") do |log| 
      testdata = [[ "Nr", "Beschreibung", "Groesse", "Preis"], *items_list]
      log.puts "#{transaction} #{id}"
      testdata.each do |a|
        log.puts a.inspect
        log.puts Array === a
      end
      log.print "assert_propper_table_data: "
      log.puts testdata.all? { |a| Array === a }
    end
    # DEBUGGING END

    pdf.table([[ "Nr", "Beschreibung", "Groesse", "Preis"], *items_list], 
              cell_style: { size: 10, padding: 2 }, 
              column_widths: [40, 340, 71, 70]) do |t|
      t.header = true
      t.columns(0).align = :center
      t.columns(1).align = :left
      t.columns(2).align = :right
      t.columns(3).align = :right
      t.row(0).style(background_color: '44844', text_color: 'ffffff')
      t.row(0).font_style = :bold
      t.row(0).columns(0..3).align = :center
    end

    pdf.table([[ "Total", transaction_number_format(transaction, total) ]],
              cell_style: { size: 10, padding: 2},
              column_widths: [451, 70]) do |t|
      pdf.font pdf.font.name, style: :bold
      t.columns(0).align = :left
      t.columns(1).align = :right
    end

    pdf.repeat(:all) do
      pdf.text_box(header_left, options = {
        at: pdf.bounds.top_left,
        width: pdf.bounds.width,
        align: :left,
        single_line: true,
        size: 10
      })

      pdf.text_box(header_center, options = {
        at: pdf.bounds.top_left,
        width: pdf.bounds.width,
        align: :center,
        single_line: true,
        size: 10
      })
      
      pdf.text_box(header_right, options = {
        at: pdf.bounds.top_left,
        width: pdf.bounds.width,
        align: :right,
        single_line: true,
        size: 10
      })
    end

    pdf.repeat(:all, dynamic: true) do
      pdf.text_box(footer_left, options = {
        at: [pdf.bounds.left, 12],
        width: pdf.bounds.width,
        align: :left,
        valign: :bottom,
        single_line: true,
        size: 10
      })

      pdf.text_box(footer_center, options = {
        at: [pdf.bounds.left, 12],
        width: pdf.bounds.width,
        align: :center,
        valign: :bottom,
        single_line: true,
        size: 10
      })

      pdf.number_pages "<page>/<total>",
                       { start_count_at: 1,
                         at: [pdf.bounds.right - 50, 10],
                         align: :right,
                         size: 10 }
    end

    pdf.render_file("tmp/selling_#{id}.pdf")

  end

  private

    def cut_to_fit(pdf, width, value)
      return value if pdf.width_of(value) <= width
      words = value.split(" ")
      if words.size > 1
        words.each_with_index do |word,i|
          return words[0..i-1].
            join(" ") + " ..." if pdf.width_of(words[0..i].join(" ")) > width
        end
      else
        (value.size - 1).step(0, -1) do |i|
          return value[0..i] + " ..." if pdf.width_of(value[0..i]) <= width
        end
      end
    end

    def transaction_number_format(transaction, value)
      if (transaction == "Verkauf")
        number_to_currency(value, locale: :de)
      else
        number_to_currency("-#{value}", locale: :de)
      end
    end

end
