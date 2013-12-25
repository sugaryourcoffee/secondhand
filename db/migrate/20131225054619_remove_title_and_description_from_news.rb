class RemoveTitleAndDescriptionFromNews < ActiveRecord::Migration
  def up
    remove_column :news, :title
    remove_column :news, :description
  end

  def down
    add_column :news, :title, :string
    add_column :news, :description, :text
  end
end
