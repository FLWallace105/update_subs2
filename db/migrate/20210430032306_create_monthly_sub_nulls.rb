class CreateMonthlySubNulls < ActiveRecord::Migration[5.1]
  def change
    create_table :monthly_sub_nulls do |t|
      t.string :subscription_id
      t.string :old_product_id
      t.string :old_product_title
      
      

    end

  end
end
