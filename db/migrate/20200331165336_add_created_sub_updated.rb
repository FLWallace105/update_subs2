class AddCreatedSubUpdated < ActiveRecord::Migration[5.1]
  def up
    add_column :subscriptions_updated, :created_at, :datetime
    
  end

  def down
    remove_column :subscriptions_updated, :created_at, :datetime
    
  end
end
