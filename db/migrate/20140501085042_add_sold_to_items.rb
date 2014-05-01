class AddSoldToItems < ActiveRecord::Migration
  def change
    add_column :items, :sold, :boolean, default: false
  end
end
