class RemoveStripeSubscriptionIdFromCompanies < ActiveRecord::Migration[7.0]
  def change
    remove_column :companies, :stripe_subscription_id
  end
end
