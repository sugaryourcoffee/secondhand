class AddSellingIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :selling_id, :integer
  end
end
