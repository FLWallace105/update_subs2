class FixNextMonthType < ActiveRecord::Migration[5.1]
  
  def up
    
    change_column :current_products, :next_month_prod_id, :string
    
  end

  def down
    change_column :current_products, :next_month_prod_id, :text
    
  end


  
end
