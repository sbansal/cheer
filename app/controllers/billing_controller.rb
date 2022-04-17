class BillingController < ApplicationController
  def create
    Stripe.api_key = Rails.application.credentials[:stripe][:api_key]
    subscription_identifier = find_subscription_plan(params[:plan])
    session = session = Stripe::Checkout::Session.create(
      {
        customer_email: current_user.email,
        success_url: Rails.application.credentials[:stripe][:success_url],
        cancel_url: Rails.application.credentials[:stripe][:cancel_url],
        mode: 'subscription',
        line_items: [
          {
            quantity: 1,
            price: subscription_identifier,
          }
        ],
      }
    )
    redirect_to(session.url, status: 303, allow_other_host: true)
  end

  def success
    redirect_to accounts_settings_path
  end

  private

  def find_subscription_plan(type)
    plan = nil
    if type == 'monthly'
      plan = Rails.application.credentials[:stripe][:monthly_plan]
    elsif type == 'annual'
      plan = Rails.application.credentials[:stripe][:annual_plan]
    else
      Rails.logger.error("Unknown subscription plan")
    end
    plan
  end
end
