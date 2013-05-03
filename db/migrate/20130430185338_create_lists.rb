class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.integer :list_number
      t.string :registration_code
      t.string :container
      t.integer :event_id
      t.integer :user_id

      t.timestamps
    end
  end
end
