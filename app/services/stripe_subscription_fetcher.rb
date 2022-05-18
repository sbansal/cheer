class StripeSubscriptionFetcher < ApplicationService
  def initialize(stripe_subscription_id)
    @stripe_subscription_id = stripe_subscription_id
  end

  require 'stripe'
  def call
    Stripe.api_key = Rails.application.credentials[:stripe][:api_key]
    Stripe::Subscription.retrieve(@stripe_subscription_id) if @stripe_subscription_id
  end
end