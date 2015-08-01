# == Schema Information
#
# Table name: events
#
#  id                 :integer          not null, primary key
#  title              :string(255)
#  event_date         :datetime
#  location           :string(255)
#  fee                :decimal(2, 2)
#  deduction          :decimal(2, 2)
#  provision          :decimal(2, 2)
#  max_lists          :integer
#  max_items_per_list :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  active             :boolean          default(FALSE)
#

class Event < ActiveRecord::Base

  include EventPrinters

  has_many :lists, dependent: :destroy
  has_many :users, through: :lists
  has_many :sellings, dependent: :destroy

  attr_accessible :deduction, :event_date, :fee, :location, 
    :max_items_per_list, :max_lists, :provision, :title, :active, 
    :information,
    :list_closing_date, 
    :delivery_location, 
    :delivery_date, :delivery_start_time, :delivery_end_time, 
    :collection_location, 
    :collection_date, :collection_start_time, :collection_end_time

  validates :deduction, :event_date, :fee, :location, :max_items_per_list,
    :max_lists, :provision, :title, presence: true

  validates :deduction, :fee, :max_items_per_list, :max_lists, :provision, 
    numericality: {greater_than_or_equal_to: 1}

  validates :deduction, :fee, divisable: {divisor: 0.5}

  before_destroy :ensure_not_active, :ensure_has_no_registered_lists

  # Returns the registered lists for the this event
  def registered_lists
    List.registered(id)
  end

  # Returns the open (not registered) lists for this event
  def open_lists
    List.open(id)
  end

  # Returns the closed (sent) lists for this event
  def closed_lists
    List.closed(id)
  end

  # Returns the registered but not closed (sent) lists for this event
  def not_closed_lists
    List.not_closed(id)
  end

  def pickup_tickets_pdf
    list_index = 0
    pdf = Prawn::Document.new(page_size: "A4")
    page_height = pdf.bounds.height
    label_height = page_height / 10
    label_width  = pdf.bounds.width
    pages = (
              (lists.size / 10) + (0.5 * (lists.size % 10 > 0 ? 1 : 0))
            ).round

    pdf.repeat(:all) do
      pdf.number_pages "#{title}",
                       { # start_count_at: 1,
                         at: [pdf.bounds.left, pdf.bounds.top + 15],
                         align: :center,
                         size: 10 }
    end

#    pdf.repeat(:all, dynamic: true) do
#      pdf.number_pages "<page>/<total>",
#                       { start_count_at: 1,
#                         at: [pdf.bounds.left, -10],
#                         align: :right,
#                         size: 10 }
#    end

    1.upto(pages) do |page|
      page_height.step(label_height, -label_height) do |y|
        x = 0
        pdf.bounding_box([x,y], width: label_width, height: label_height) do
          pdf.dash(2, space: 2, phase: 0)
          pdf.transparent(0.5) { pdf.stroke_bounds }

          pdf.move_down 3
          pdf.text "#{title} - "+
            "Listennummer: <b>#{lists[list_index].list_number}</b> - "+
            "Registrierungscode: <b>#{lists[list_index].registration_code}</b>",
            align: :center,
            inline_format:true

          message = "Termin Listenruecksendung #{list_closing_date}\n"+
                    "Abgabe Koerbe: #{delivery_date}, "+
                    "#{delivery_start_time.to_s(:time)}"+
                    " bis #{delivery_end_time.to_s(:time)} Uhr "+
                    "#{delivery_location}\n"+
                    "Abholen Koerbe: #{collection_date}, "+
                    "#{collection_start_time.to_s(:time)}"+
                    " bis #{collection_end_time.to_s(:time)} Uhr "+
                    "#{collection_location}\n"+
                    "Ausgabe der Koerbe nur gegen Vorlage "+
                    "dieses Ausgabescheins\n"+
                    "Informationen: www.boerse-burgthann.de - "+
                    "Menue 'Infos fuer Verkaeufer' - Alle Informationen "+
                    "vorher lesen!"

          pdf.text_box(message,
                       at: [x+2, pdf.cursor],
                       width: label_width-4, height: label_height-19,
                       overflow: :shrink_to_fit)

        end
        list_index += 1 
        break if list_index > lists.size - 1
      end
      pdf.start_new_page if page < pages 
    end
    pdf.render
  end

  private

    def ensure_not_active
      if self.active
        errors.add(:base, 'Cannot delete active event')
        false
      else
        true
      end
    end

    def ensure_has_no_registered_lists
      if self.users.empty?
        true
      else
        errors.add(:base, 'Cannot delete event with registered lists')
        false
      end
    end

end
