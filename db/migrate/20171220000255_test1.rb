class Test1 < ActiveRecord::Migration[5.1]
  def up
    add_column :current_products, :next_month_prod_id, :text
    
  end

  def down
     remove_column :current_products, :next_month_prod_id, :text
    
  end
end
