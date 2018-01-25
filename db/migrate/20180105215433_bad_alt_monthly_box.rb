class BadAltMonthlyBox < ActiveRecord::Migration[5.1]
  def up
    create_table :bad_monthly_box do |t|
      t.string :subscription_id
      t.boolean :updated, default: false
      t.datetime :updated_at
      

    end
  end

  def down
    drop_table :bad_monthly_box
  end


end
