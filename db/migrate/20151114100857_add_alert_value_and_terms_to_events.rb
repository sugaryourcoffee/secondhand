class AddAlertValueAndTermsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :alert_terms, :string
    add_column :events, :alert_value, :integer, default: 20
  end
end
