class AddCartIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :cart_id, :integer
  end
end
