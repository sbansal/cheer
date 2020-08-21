class AddBankAccountToSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_index :subscriptions, [:bank_account_id, :frequency, :description], :unique => true, :name => 'unique_subscriptions_by_frequency'
  end
end
