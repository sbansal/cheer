class StripeCustomerCreator < ApplicationService
  def initialize(user_id)
    @user = User.find(user_id)
  end

  require 'stripe'
  def call
    Stripe.api_key = Rails.application.credentials[:stripe][:api_key]
    customer = Stripe::Customer.create({
      description: @user.company.name,
      name: @user.full_name,
      email: @user.email,
    })
    @user.update(stripe_customer_id: customer.id)
    return @user.stripe_customer_id
  end

end