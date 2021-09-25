class AddEmailSubs < ActiveRecord::Migration[5.1]
  def change
    add_column :subscriptions, :email, :string
  end
end
