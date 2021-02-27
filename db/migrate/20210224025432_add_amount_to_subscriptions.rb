class AddAmountToSubscriptions < ActiveRecord::Migration[6.1]
  def up
    add_column :subscriptions, :amount, :float
    add_index :subscriptions, [:bank_account_id, :frequency, :description, :amount], :unique => true, :name => 'unique_subscriptions_by_frequency', if_not_exists: true
  end

  def down
    remove_column :subscriptions, :amount
    remove_index :subscriptions, :name => 'unique_subscriptions_by_frequency', if_exists: true
  end
end
