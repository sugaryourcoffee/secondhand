class AddPrivacyStatementToUser < ActiveRecord::Migration
  def change
    add_column :users, :privacy_statement, :boolean, default: false
  end
end
