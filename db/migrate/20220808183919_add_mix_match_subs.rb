class AddMixMatchSubs < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :is_mix_match, :boolean, default: false
  end
end
