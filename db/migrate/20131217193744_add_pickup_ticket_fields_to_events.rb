class AddPickupTicketFieldsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :list_closing_date, :date
    add_column :events, :delivery_date, :date
    add_column :events, :delivery_start_time, :time
    add_column :events, :delivery_end_time, :time
    add_column :events, :delivery_location, :string
    add_column :events, :collection_date, :date
    add_column :events, :collection_start_time, :time
    add_column :events, :collection_end_time, :time
    add_column :events, :collection_location, :string
  end
end
