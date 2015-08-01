class AddInformationToEvents < ActiveRecord::Migration
  def change
    add_column :events, :information, :string
  end
end
