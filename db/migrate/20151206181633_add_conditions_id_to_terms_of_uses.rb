class AddConditionsIdToTermsOfUses < ActiveRecord::Migration
  def change
    add_column :terms_of_uses, :conditions_id, :integer
  end
end
