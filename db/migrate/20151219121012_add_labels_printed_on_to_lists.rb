class AddLabelsPrintedOnToLists < ActiveRecord::Migration
  def change
    add_column :lists, :labels_printed_on, :datetime
  end
end
