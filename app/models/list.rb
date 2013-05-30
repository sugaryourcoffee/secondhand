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

  attr_accessible :container, :event_id, :list_number, :registration_code, :user_id

  def list_pdf
    items_list = items.map do |item|
      [item.number, item.description, item.size, item.price]
    end

    pdf = Prawn::Document.new
    pdf.table([[ "Number", "Description", "Size", "Price"], *items_list]) do |t|
      t.header = true
      t.row(0).style(background_color: '44844', text_color: 'ffffff')
      t.columns(1).align = :right
    end
    pdf.render
  end

  def labels_pdf
    items_list = items.map do |item|
      [item.number, item.description, item.size, item.price]
    end

    create_pdf_labels items_list
  end

  private

  def create_pdf_labels(items_list)
    pdf = Prawn::Document.new
    pdf.text("Needs to be implemented")
    pdf.render
  end

end
