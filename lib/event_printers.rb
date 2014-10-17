module EventPrinters

  def lists_to_pdf
    pdf = Prawn::Document.new(page_size: "A4")

    self.lists.each do |list|
      next unless list.registered?
      list_to(pdf, list)
      pdf.start_new_page
    end

    pdf.render
  end

  def list_to(pdf, list)
    header_left   = self.title
    header_center = "www.boerse-burgthann.de"
    header_right  = "Liste #{list.list_number}"

    footer_left   = Time.now.strftime("%Y-%m-%d / %H:%M")
    footer_center = "mail@boerse-burgthann.de"

    user = list.user

    seller_label = "Seller:"
    seller_contact = "#{user.first_name} #{user.last_name}\n" +
                     "#{user.street}\n" +
                     "#{user.zip_code} #{user.town}\n" +
                     "#{user.phone}"

    container_label = "Korbfarbe:"
    container_color = list.container || "-"

    items_list = (list.items.sort_by { |item| item.item_number }).map do |item|
      [item.item_number, 
       item.sold? ? 'X' : ' ',
       ' ',
       cut_to_fit(pdf, 400, item.description), 
       cut_to_fit(pdf, 71, item.size), 
       helpers.number_to_currency(item.price, locale: :de)]
    end

    pdf.text_box(seller_label, options = {
        at: [pdf.bounds.left, pdf.bounds.top - 25],
        width: 50,
        align: :left,
        size: 10
      })

    pdf.text_box(seller_contact, options = {
      at: [pdf.bounds.left + 50, pdf.bounds.top - 25],
      width: 200,
      align: :left,
      size: 10
    })

    pdf.text_box(container_label, options = {
        at: [pdf.bounds.left + 300, pdf.bounds.top - 25],
        width: 60,
        align: :left,
        size: 10
      })

    pdf.text_box(container_color, options = {
      at: [pdf.bounds.left + 360, pdf.bounds.top - 25],
      width: 200,
      align: :left,
      size: 10
    })

    pdf.move_down 85

    pdf.table([[ "No", "Sold", "3. Quality", "Description", "Size", "Price"], *items_list], 
              cell_style: { size: 10, padding: 2 }, 
              column_widths: [29, 30, 30, 290, 71, 71]) do |t|
      t.header = true
      t.columns(0).align = :right
      t.columns(1).align = :center
      t.columns(2).align = :center
      t.columns(3).align = :left
      t.columns(4).align = :right
      t.columns(5).align = :right
      t.row(0).style(background_color: '44844', text_color: 'ffffff')
      t.row(0).font_style = :bold
      t.row(0).columns(0..3).align = :center
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

  end

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

  private
   
    # Returns the helpers
    def helpers
      ActionController::Base.helpers
    end

end
