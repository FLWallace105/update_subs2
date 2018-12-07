class CreateToughLuxe < ActiveRecord::Migration[5.1]
  def up
    create_table :tough_luxe_subs do |t|
      t.string :email
      t.boolean :found_customer, default: false
      

    end
  end

  def down
    drop_table :tough_luxe_subs
  end
end
