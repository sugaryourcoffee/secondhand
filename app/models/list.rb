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

  def list_pdf

    header_left   = event.title
    header_center = "www.boerse-burgthann.de"
    header_right  = "Liste #{self.list_number}"

    items_list = items.map do |item|
      [item.item_number, item.description, item.size, item.price]
    end

    pdf = Prawn::Document.new
    pdf.move_down 10
    pdf.table([[ "No", "Description", "Size", "Price"], 
               *items_list], column_widths: [30, 350, 80, 80]) do |t|
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
      pdf.draw_text header_left, at: pdf.bounds.top_left
      pdf.draw_text header_center, at: [pdf.bounds.left+200,pdf.bounds.top]
      pdf.draw_text header_right, at: pdf.bounds.top_right
    end

    pdf.repeat(:all, dynamic: true) do
      pdf.number_pages "<page>/<total>",
                       { start_count_at: 1,
                         at: [pdf.bounds.right - 50, 0],
                         align: :right,
                         size: 14 }
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
    pdf.render
  end

end
