class BadRecurringSubs < ActiveRecord::Migration[5.1]
  def up
    create_table :bad_recurring_subs do |t|
      t.string :subscription_id
      t.string :customer_id
      t.datetime :next_charge_scheduled_at
      t.decimal :price, precision: 10, scale: 2
      t.string :status
      t.string :product_title
      t.string :product_id
      t.string :variant_id
      t.string :sku
      t.jsonb :line_item_properties
      t.boolean :updated, default: false
      t.datetime :updated_at
      t.integer :expire_after_specific_number_charges
      

    end
  end

  def down
    drop_table :bad_recurring_sub
  end
end
