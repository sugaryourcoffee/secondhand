class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.integer :number
      t.string :title
      t.text :content
      t.references :terms_of_use, index: true

      t.timestamps
    end
  end
end
