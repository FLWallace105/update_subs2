class AddMixMatchOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :is_mix_match, :boolean, default: false
  end
end
