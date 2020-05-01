class CreateSubsUpdatedInventorySize < ActiveRecord::Migration[5.1]
  def change
    create_table :subs_updated_inventory_sizes do |t|
      t.string :product_type
      t.string :product_size
      t.integer :inventory_avail
      t.integer :inventory_assigned
      

    end

  end
end
