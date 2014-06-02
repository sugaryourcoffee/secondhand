class AddEventIdToReversals < ActiveRecord::Migration
  def change
    add_column :reversals, :event_id, :integer
  end
end
