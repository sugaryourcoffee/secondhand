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

class List < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  has_many :items

  attr_accessible :container, :event_id, :list_number, :registration_code, 
                  :user_id

  before_destroy :ensure_not_registered_by_a_user

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
    container_color = container

    items_list = items.map do |item|
      [item.item_number, item.description, item.size, item.price]
    end

    pdf = Prawn::Document.new(page_size: "A4")

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

  def labels_pdf
    items_list = items.map do |item|
      [item.number, item.description, item.size, item.price]
    end

    create_pdf_labels items_list
  end

  def next_item_number
    numbers = Array.new(40)
    numbers.fill { |i| i + 1 }
    numbers -= items.map { |i| i.item_number }    
    numbers.first
  end

  private

  def create_pdf_labels(items_list)
    pdf = Prawn::Document.new
    pdf.text("Needs to be implemented")
    barcode = Interleave2of5.new("1234")
    barcode.encode.to_pdf(pdf)
    pdf.render
  end

  def ensure_not_registered_by_a_user
    unless self.user_id.nil?
      errors.add(:base, 'Cannot delete list registered by a user')
      false
    else
      true
    end
  end

end
