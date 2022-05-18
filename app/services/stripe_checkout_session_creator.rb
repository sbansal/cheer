class StripeCheckoutSessionCreator < ApplicationService
  SUBCRIPTION_MODE = 'subscription'
  SUBSCRIPTION_TRIAL_PERIOD = 15
  def initialize(stripe_plan_id, user_email, stripe_customer_id)
    @stripe_plan_id = stripe_plan_id
    @user_email = user_email
    @stripe_customer_id = stripe_customer_id
    @user = User.find_by(email: user_email)
  end

  def call
    Stripe.api_key = Rails.application.credentials[:stripe][:api_key]
    Stripe::Checkout::Session.create(checkout_session_hash)
  end

  private

  def checkout_session_hash
    checkout_hash = {
      customer: @stripe_customer_id,
      success_url: Rails.application.credentials[:stripe][:success_url],
      cancel_url: Rails.application.credentials[:stripe][:cancel_url],
      mode: SUBCRIPTION_MODE,
      line_items: [
        {
          quantity: 1,
          price: @stripe_plan_id,
        }
      ],
    }
    if @user.has_no_subscription?
      # add 15 day trial
      checkout_hash[:subscription_data] = {
        trial_period_days: SUBSCRIPTION_TRIAL_PERIOD,
      }
    end
    checkout_hash
  end
end