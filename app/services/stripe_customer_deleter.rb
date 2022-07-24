class StripeCustomerDeleter < ApplicationService
  def initialize(stripe_customer_id)
    @stripe_customer_id = stripe_customer_id
  end

  require 'stripe'
  def call
    Stripe.api_key = Rails.application.credentials[:stripe][:api_key]
    Stripe::Customer.delete(@stripe_customer_id)
  end
end