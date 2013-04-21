class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.datetime :event_date
      t.string :location
      t.decimal :fee, precision: 2, scale: 2
      t.decimal :deduction, precision: 2, scale: 2
      t.decimal :provision, precision: 2, scale: 2
      t.integer :max_lists
      t.integer :max_items_per_list

      t.timestamps
    end
  end
end
