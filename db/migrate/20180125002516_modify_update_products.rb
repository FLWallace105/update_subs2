class ModifyUpdateProducts < ActiveRecord::Migration[5.1]
  def up
    add_column :update_products, :product_collection, :string
    
  end

  def down
    remove_column :update_products, :product_collection, :string
    
  end
  

end
