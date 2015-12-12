class AddLocaleToTermsOfUses < ActiveRecord::Migration
  def change
    remove_column :terms_of_uses, :active, :boolean
    add_column :terms_of_uses, :locale, :string
  end
end
