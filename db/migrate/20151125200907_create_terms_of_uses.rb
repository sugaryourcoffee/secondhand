class CreateTermsOfUses < ActiveRecord::Migration
  def change
    create_table :terms_of_uses do |t|
      t.boolean :active

      t.timestamps
    end
  end
end
