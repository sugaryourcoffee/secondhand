# == Schema Information
#
# Table name: lists
#
#  id                :integer          not null, primary key
#  list_number       :integer
#  registration_code :string(255)
#  container         :string(255)
#  event_id          :integer
#  user_id           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
require 'csv'
require 'open3'
require 'calculator'

class List < ActiveRecord::Base

  include ActionView::Helpers::NumberHelper

  belongs_to :user
  belongs_to :event
  has_many :items

  validates :event_id, :list_number, :registration_code, presence: true

  before_destroy :ensure_not_registered_by_a_user

  before_update :reset_sent_on

  # Returns true if the list has been registered
  def registered?
    not user.nil?
  end

  # Returns true if the list is acceptable, that is that the container color
  # is available
  def acceptable?
    not (container.nil? || container.empty?)
  end

  # Returns true if the list has been accepted
  def accepted?
    not accepted_on.nil?
  end

  # Returns whether the list has sold items
  def has_sold_items?
    items.each do |item|
      return true if item.sold?
    end
    false
  end
 
  # Calculates the total amount of sold items and the payback. Determines
  # the provision and whether the fee is returned
  #
  #   cash_up -> [total, provision, fee, payback]
  #
  # provision and payback is rounded to 0.5 cent
  def cash_up
    total = 0
    items.each { |item| total += item.price if item.sold? }

    provision = if total > 19 
                  Calculator.round_base(total * event.provision / 100, 0.5)
                else
                  0
                end

    fee = total > 19 ? event.fee : 0

    payback = total - provision + fee

    [total, provision, fee, payback] 
  end 

  # Returns the list count for the provided event_id
  def self.total_count(event_id)
    List.where(event_id: event_id)
  end

  # Returns all registered and not send (closed) lists for the provided event
  def self.registered(event_id)
    condition = "user_id is not ?"
    if event_id
      condition = "event_id = ? and " + condition
    end
    List.where(condition, event_id, nil)
  end

  # Returns all not registered lists for the provided event
  def self.not_registered(event_id)
    condition = "user_id is ?"
    if event_id
      condition = "event_id = ? and " + condition
    end
    List.where(condition, event_id, nil)
  end

  # Returns all closed (send) lists for the provided event
  def self.closed(event_id)
    condition = "sent_on is not ?"
    if event_id
      condition = "event_id = ? and " + condition
    end
    List.where(condition, event_id, nil)
  end

  # Returns all registered but not closed (send) lists for the provided event
  def self.not_closed(event_id)
    condition = "user_id is not ? and sent_on is ?"
    if event_id
      condition = "event_id = ? and " + condition
    end
    List.where(condition, event_id, nil, nil)
  end

  # Returns all unregistered lists for the provided event
  def self.open(event_id)
    condition = "user_id is ?"
    if event_id
      condition = "event_id = ? and " + condition
    end
    List.where(condition, event_id, nil)
  end

  # Returns accepted list count
  def self.accepted(event_id)
    condition = "accepted_on is not ?"
    if event_id
      condition = "event_id = ? and " + condition
    end
    List.where(condition, event_id, nil)
  end

  # Returns not accepted list count
  def self.not_accepted(event_id)
    condition = "accepted_on is ? and user_id is not ?"
    if event_id
      condition = "event_id = ? and " + condition
    end
    List.where(condition, event_id, nil, nil)
  end

  # Searches for the provided registration code or list number
  def self.search(search)
    if search
#      find(:all,
#           conditions: ['list_number = ? or registration_code LIKE ?', 
#                        search, "%#{search}%"])
       where('list_number = ? or registration_code LIKE ?', 
             search, "%#{search}%")
    else
      all # find(:all)
    end
  end

  # Searches for lists that meet the provided list values
  def self.search_conditions(params)
    if params[:search]
      ['(list_number = ? or registration_code LIKE ?) and event_id = ?', 
       params[:search], "%#{params[:search]}%", params[:search_event_id]]
    else
      search_params = params.select { |k,v| not v.empty? and k =~ /^search_/ }
      unless search_params.empty?
        query_string = ""
        values       = []
        first_value  = true
        search_params.each do |k,v|
          if first_value
            first_value = false
          else
            query_string << " and "
          end

          key = k.sub("search_", "")

          if key == "user_id" or key == "sent_on" or key == "accepted_on"
            query_string << "#{key} IS NOT ?" if v == "0"
            query_string << "#{key} IS ?" if v == "1"
            values << nil 
          else
            query_string << "#{key} LIKE ?"
            values << "%#{v}%"
          end
        end
        [query_string, values].flatten
      else
        nil
      end
    end
  end

  def self.list_status_query_string(filter)
    query_string = "event_id = ? "
    query_values = [Event.find_by(active: true).id] #find_by_active(true).id]
    case filter.nil? ? :not_accepted : filter.to_sym
    when :accepted
      query_string << "AND accepted_on iS NOT ?"
      query_values << nil
    when :not_accepted
      query_string << "AND accepted_on IS ? AND user_id IS NOT ?"
      query_values << [nil, nil]
    when :registered
      query_string << "AND user_id IS NOT ?"
      query_values << nil
    when :not_registered
      query_string << "AND user_id IS ?"
      query_values << nil
    when :all
      query_string
    end
    [query_string, query_values].flatten
  end

  def as_csv
    (data = "").tap do
      CSV.generate(data, encoding: 'u', col_sep: ';') do |csv|
        to_csv(csv)
      end
    end
  end

  def as_csv_file
    csv_file = "tmp/#{sprintf("%03d", list_number)}.csv"
    CSV.open(csv_file, 'w', encoding: 'u', col_sep: ';') do |csv|
      to_csv(csv)
    end
    csv_file
  end

  def self.as_csv_zip
    download_file = "tmp/csv.tgz"
    files = []

    closed_lists = List.where('sent_on IS NOT ?', nil)

    if closed_lists.empty?
      File.write("tmp/no_closed_files", I18n.t('.no_closed_files_to_zip'))
      files << "tmp/no_closed_files"
    else
      closed_lists.each { |list| files << list.as_csv_file }
    end

    tar_command = "tar czf #{download_file} #{files.join(" ")}"
    stdout, stderr, status = Open3.capture3(tar_command)

    unless status.exitstatus == 0
      raise stderr
    end

    download_file
  end

  def list_pdf

    header_left   = event.title
    header_center = "www.boerse-burgthann.de"
    header_right  = "Liste #{self.list_number}"

    footer_left   = Time.now.strftime("%Y-%m-%d / %H:%M")
    footer_center = "mail@boerse-burgthann.de"

    seller_label = "Seller:"
    seller_contact = "#{user.first_name} #{user.last_name}\n" +
                     "#{user.street}\n" +
                     "#{user.zip_code} #{user.town}\n" +
                     "#{user.phone}"

    container_label = "Korbfarbe:"
    container_color = container || "-"

    pdf = Prawn::Document.new(page_size: "A4")

    items_list = (items.sort_by { |item| item.item_number }).map do |item|
      [item.item_number, 
       cut_to_fit(pdf, 400, item.description), 
       cut_to_fit(pdf, 71, item.size), 
       number_to_currency(item.price, locale: :de)]
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

    pdf.table([[ "No", "Description", "Size", "Price"], *items_list], 
              cell_style: { size: 10, padding: 2 }, 
              column_widths: [29, 350, 71, 71]) do |t|
      t.header = true
      t.columns(0).align = :right
      t.columns(1).align = :left
      t.columns(2).align = :right
      t.columns(3).align = :right
      t.row(0).style(background_color: '44844', text_color: 'ffffff')
      t.row(0).font_style = :bold
      t.row(0).columns(0..3).align = :center
    end

    pdf.table([[ "Total", number_to_currency(total_value, locale: :de) ]],
              cell_style: { size: 10, padding: 2},
              column_widths: [450, 71]) do |t|
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

    pdf.render
  end

  # Creates the labels for the list's items. If as_file is true the labels will
  # be saved to a pdf-file and the file is returned. Otherwise the pdf-file will
  # be offered to the user to be opened or to be saved.
  def labels_pdf(as_file=false)
    items_list = (items.sort_by { |item| item.item_number }).map do |item|
      [item.item_number, item.description, item.size, item.price]
    end

    create_pdf_labels(items_list, as_file)
  end

  def next_item_number
    return 0 if event.nil?

    numbers = Array.new(event.max_items_per_list)
    numbers.fill { |i| i + 1 }
    numbers -= items.map { |i| i.item_number }    
    numbers.first
  end

  def max_items_per_list?
    event.nil? or event.max_items_per_list == items.size
  end

  def free_item_capacity
    return 0 if event.nil?
    event.max_items_per_list - items.size 
  end

  def total_value
    items.inject(0) do |total, item| 
      total + (item.price.nil? ? 0 :  item.price)
    end
  end

  private

  def create_pdf_labels(items_list, as_file=false)
    item_index = 0
    pdf_options = { height: 30, width: 1, factor: 2, y: 10 }
    pdf = Prawn::Document.new(page_size: "A4")
    page_height = pdf.bounds.height
    label_height = page_height / 10
    label_width  = pdf.bounds.width / 2
    pages = (
              (items_list.size / 20) + (0.5 * items_list.size % 20 > 0 ? 1 : 0)
            ).round

    pdf.repeat(:all) do
      pdf.number_pages "#{event.title} - List #{list_number}",
                       { # start_count_at: 1,
                         at: [pdf.bounds.left, pdf.bounds.top + 15],
                         align: :center,
                         size: 10 }
    end

#    pdf.repeat(:all) do
#      pdf.number_pages "<page>/<total>",
#                       { start_count_at: 1,
#                         at: [pdf.bounds.left, -10],
#                         align: :right,
#                         size: 10 }
#    end

    1.upto(pages) do |page|
      page_height.step(label_height, -label_height) do |y|
        0.step(label_width, label_width) do |x|
          pdf.bounding_box([x,y], width: label_width, height: label_height) do
            pdf.dash(2, space: 2, phase: 0)
            pdf.transparent(0.5) { pdf.stroke_bounds }

            pdf.text_box(items_list[item_index][1], 
                         at: [4, label_height - 4],
                         size: 10,
                         width: label_width - 8,
                         height: 30)

            value = sprintf("%03d%02d", list_number, items_list[item_index][0])
            barcode = Interleave2of5.new(value).encode.to_pdf(pdf, pdf_options)

            value[3,0] = "/"
            pdf.text_box(value, at: [0,15], 
                         width: barcode[:total_width], 
                         height: 20,
                         align: :center)

            pdf.fill_ellipse([barcode[:total_width] + 10, label_height / 2], 5)
            
            pdf.bounding_box([barcode[:total_width] + 20, 
                             barcode[:total_height] + 7],
                             width: label_width - barcode[:total_width]) do
          
              pdf.table(
                [
                  ["Size:",  cut_to_fit(pdf, 90, items_list[item_index][2])],
                  ["Price:", number_to_currency(items_list[item_index][3], 
                                                locale: :de)]
                ],
                cell_style: { borders: [] })
            end
          end
          item_index += 1 
          break if item_index > items_list.size - 1
        end
        break if item_index > items_list.size - 1
      end
      pdf.start_new_page if page < pages 
    end

    if as_file
      label_file = "tmp/list-#{list_number}-labels.pdf"
      pdf.render_file(label_file)
      File.absolute_path(label_file)
    else
      pdf.render
    end

  end

  def cut_to_fit(pdf, width, value)
    return value if pdf.width_of(value) <= width
    words = value.split(" ")
    if words.size > 1
      words.each_with_index do |word,i|
        return words[0..i-1].
          join(" ") + " ..." if pdf.width_of(words[0..i].join(" ")) >= width
      end
      return words[0..words.size-1].join(" ") + " ..."
    else
      (value.size - 1).step(0, -1) do |i|
        return value[0..i] + " ..." if pdf.width_of(value[0..i]) <= width
      end
    end
  end

  def to_csv(csv)
    csv << ["Listennummer", list_number]
    csv << ["Name", user.last_name]
    csv << ["Vorname", user.first_name]
    csv << ["Strasse", user.street]
    csv << ["PLZ", user.zip_code]
    csv << ["Stadt", user.town]
    csv << ["Telefon", user.phone]
    csv << ["E-Mail", user.email]
    csv << ["Korbfarbe", container || "-"]
    csv << ["Nummer", "Beschreibung", "Groesse", "Preis"]
    (items.sort_by { |item| item.item_number }).each do |item|
      csv << [item.item_number, 
              item.description.gsub(';', ','), 
              item.size.gsub(';', ','), 
              item.price]
    end
  end

  def ensure_not_registered_by_a_user
    unless self.user_id.nil?
      errors.add(:base, 'Cannot delete list registered by a user')
      false
    else
      true
    end
  end

  def reset_sent_on
    self.sent_on = nil unless sent_on_changed?
  end

end
