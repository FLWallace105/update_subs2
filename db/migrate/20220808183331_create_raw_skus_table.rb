class CreateRawSkusTable < ActiveRecord::Migration[6.1]
  def change
    create_table :sub_raw_skus do |t|
      t.string :subscription_id
      t.datetime :next_charge_scheduled_at
      t.boolean :prepaid, default: false
      t.string :sku
    end
  end
end
