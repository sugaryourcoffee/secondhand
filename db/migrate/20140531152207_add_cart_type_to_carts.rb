class AddCartTypeToCarts < ActiveRecord::Migration
  def change
    add_column :carts, :cart_type, :string, default: 'SALES'
  end
end
