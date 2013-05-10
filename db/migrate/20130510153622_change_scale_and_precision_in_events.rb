class ChangeScaleAndPrecisionInEvents < ActiveRecord::Migration
  def up
    change_column(:events, :fee, :decimal, precision: 5, scale: 2)
    change_column(:events, :deduction, :decimal, precision: 5, scale: 2)
    change_column(:events, :provision, :decimal, precision: 4, scale: 2)
  end

  def down
  end
end
