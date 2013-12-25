class CreateNewsTranslations < ActiveRecord::Migration
  def change
    create_table :news_translations do |t|
      t.string :title
      t.text :description
      t.string :language
      t.integer :news_id

      t.timestamps
    end
  end
end
