class AddTermsOfUseToUsers < ActiveRecord::Migration
  def change
    add_column :users, :terms_of_use, :datetime
  end
end
