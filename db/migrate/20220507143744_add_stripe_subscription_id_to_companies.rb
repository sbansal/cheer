class AddStripeSubscriptionIdToCompanies < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :stripe_subscription_id, :string
  end
end
