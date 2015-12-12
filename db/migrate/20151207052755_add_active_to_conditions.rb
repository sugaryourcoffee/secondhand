class AddActiveToConditions < ActiveRecord::Migration
  def change
    add_column :conditions, :active, :boolean
  end
end
