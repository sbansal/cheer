class RemoveIndexFromSubscriptions < ActiveRecord::Migration[6.1]
  def up
    remove_index :subscriptions, :name => 'unique_subscriptions_by_frequency', if_exists: true
  end

  def down
    add_index :subscriptions, [:bank_account_id, :frequency, :description], :unique => true, :name => 'unique_subscriptions_by_frequency', if_not_exists: true
  end
end
