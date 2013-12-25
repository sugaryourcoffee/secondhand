class RemoveLanguageFromNews < ActiveRecord::Migration
  def up
    remove_column :news, :language
  end

  def down
    add_column :news, :language, :string
  end
end
