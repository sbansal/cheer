class BillingController < ApplicationController
  skip_before_action :check_subscription_active?
  def create
    plan_id = find_subscription_plan(params[:plan_type])
    session = StripeCheckoutSessionCreator.call(plan_id, current_user.email, current_user.stripe_customer_id)
    redirect_to(session.url, status: 303, allow_other_host: true)
  end

  def new
    if current_user.has_active_subscription?
      flash[:notice] = "You already have an active subscription."
      redirect_to(root_path)
    else
      @subscription = StripeSubscriptionFetcher.call(current_company.stripe_subscription_id)
      respond_to do |format|
        format.html { render layout: 'billing' }
      end
    end
  end

  def success
    flash[:notice_header] = 'Subscription successful.'
    flash[:notice] = "Your subscription has been set up successfully."
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

  def find_subscription_plan(plan_type)
    if plan_type == 'monthly'
      Rails.application.credentials[:stripe][:monthly_plan]
    else
      Rails.application.credentials[:stripe][:annual_plan]
    end
  end
end
