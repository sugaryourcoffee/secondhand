class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.integer :item_number
      t.string :description
      t.string :size
      t.decimal :price, precision: 5, scale: 2

      t.timestamps
    end
  end
end
