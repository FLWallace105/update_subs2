class CreateOrderRawSkusTable < ActiveRecord::Migration[6.1]
  def change
    create_table :order_raw_skus do |t|
     t.string :order_id
     t.datetime :scheduled_at
     t.boolean :prepaid, default: false
     t.string :sku
    end
  end
end
