class BackfillStripeCustomerToCompanies < ActiveRecord::Migration[7.0]
  def up
    User.all.each do |user|
      StripeCustomerCreator.call(user.id) unless user.stripe_customer_id.present?
    end
  end

  def down
    User.all.each do |user|
      if user.stripe_customer_id.present?
        StripeCustomerDeleter.call(user.stripe_customer_id)
        user.update(stripe_customer_id: nil)
      end
    end
  end
end
