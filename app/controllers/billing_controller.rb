class BillingController < ApplicationController
  def create
    Stripe.api_key = Rails.application.credentials[:stripe][:api_key]
    subscription_identifier = find_subscription_plan(params[:plan])
    session = Stripe::Checkout::Session.create(
      {
        customer: current_user.stripe_customer_id,
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

  def new
    respond_to do |format|
      format.html { render layout: 'billing' }
    end
  end

  def success
    redirect_to root_path
  end

  def cancel
    redirect_to new_billing_path
  end

  def manage
    Stripe.api_key = Rails.application.credentials[:stripe][:api_key]
    subscription_identifier = find_subscription_plan(params[:plan])
    session = Stripe::BillingPortal::Session.create({
      customer: current_user.stripe_customer_id,
      return_url: settings_url,
    })
    redirect_to(session.url, status: 303, allow_other_host: true)
  end

  private

  def find_subscription_plan(type)
    if type == 'monthly'
      Rails.application.credentials[:stripe][:monthly_plan]
    else
      Rails.application.credentials[:stripe][:annual_plan]
    end
  end
end
