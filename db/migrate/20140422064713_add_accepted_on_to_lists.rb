class AddAcceptedOnToLists < ActiveRecord::Migration
  def change
    add_column :lists, :accepted_on, :datetime
  end
end
