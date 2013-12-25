class AddFieldsToNews < ActiveRecord::Migration
  def change
    add_column :news, :language, :string
    add_column :news, :user_id, :integer
    add_column :news, :issue, :string
  end
end
