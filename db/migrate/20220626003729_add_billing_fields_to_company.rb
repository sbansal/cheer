class AddBillingFieldsToCompany < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :stripe_subscription_id, :string
    add_column :companies, :stripe_pricing_plan, :string
    add_column :companies, :last_payment_processed_at, :datetime
    add_column :companies, :next_payment_at, :datetime
    add_column :companies, :subscription_status, :string
    add_column :companies, :subscription_cancel_at, :datetime
    add_column :companies, :subscription_canceled_at, :datetime
    add_column :companies, :free_account, :boolean
    Company.update_all(free_account: true)
  end
end
