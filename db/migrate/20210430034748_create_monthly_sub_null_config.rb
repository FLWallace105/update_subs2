class CreateMonthlySubNullConfig < ActiveRecord::Migration[5.1]
  def change
    create_table :monthly_sub_nulls_config do |t|
      
      t.string :old_product_id
      t.string :old_product_title
      t.string :old_variant_id
      t.string :old_sku
      t.string :old_product_collection
      t.boolean :prod_info_updated, default: false
      

    end
  end
end
