class RemoveSellingIdAndCartIdFromItems < ActiveRecord::Migration
  def up
    remove_column :items, :cart_id
    remove_column :items, :selling_id
  end

  def down
    add_column :items, :cart_id, :integer
    add_column :items, :selling_id, :integer
  end
end
