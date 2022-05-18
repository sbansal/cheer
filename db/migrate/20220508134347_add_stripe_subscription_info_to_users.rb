class AddStripeSubscriptionInfoToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :stripe_subscription_id, :string
    add_column :users, :stripe_pricing_plan, :string
    add_column :users, :last_payment_processed_at, :datetime
    add_column :users, :next_payment_at, :datetime
    add_column :users, :subscription_status, :string
    add_column :users, :subscription_cancel_at, :datetime
    add_column :users, :subscription_canceled_at, :datetime
  end
end
