class AddPromoteAndReleasedToNews < ActiveRecord::Migration
  def change
    add_column :news, :promote_to_frontpage, :boolean
    add_column :news, :released, :boolean
  end
end
