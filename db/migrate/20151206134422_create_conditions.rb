class CreateConditions < ActiveRecord::Migration
  def change
    create_table :conditions do |t|
      t.string :version

      t.timestamps
    end
  end
end
