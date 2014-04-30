class AddEventIdToSellings < ActiveRecord::Migration
  def change
    add_column :sellings, :event_id, :integer
  end
end
