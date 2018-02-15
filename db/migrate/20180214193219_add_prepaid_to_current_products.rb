class AddPrepaidToCurrentProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :current_products, :prepaid, :boolean, default: false
  end
end
