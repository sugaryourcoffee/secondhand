class AddSentOnToNews < ActiveRecord::Migration
  def change
    add_column :news, :sent_on, :datetime
  end
end
