class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :street
      t.string :zip_code
      t.string :town
      t.string :country
      t.string :phone
      t.string :email
      t.string :password_digest
      t.boolean :news

      t.timestamps
    end
  end
end
