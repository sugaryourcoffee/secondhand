class AddSentOnToLists < ActiveRecord::Migration
  def change
    add_column :lists, :sent_on, :datetime
  end
end
