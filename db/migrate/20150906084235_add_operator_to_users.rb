class AddOperatorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :operator, :boolean, default: false
  end
end
