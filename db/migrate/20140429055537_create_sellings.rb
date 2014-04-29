class CreateSellings < ActiveRecord::Migration
  def change
    create_table :sellings do |t|

      t.timestamps
    end
  end
end
