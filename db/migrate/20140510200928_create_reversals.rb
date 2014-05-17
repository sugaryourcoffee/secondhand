class CreateReversals < ActiveRecord::Migration
  def change
    create_table :reversals do |t|

      t.timestamps
    end
  end
end
