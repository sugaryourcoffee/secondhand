class AddSellingIdToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :selling_id, :integer
  end
end
