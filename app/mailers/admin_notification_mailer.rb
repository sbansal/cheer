class AdminNotificationMailer < ApplicationMailer
  default to: -> { User.where(admin: true).pluck(:email) }, from: 'notifications@usecheer.com'

  require 'stripe'
  def customer_created_notification(stripe_customer_id)
    Stripe.api_key = Rails.application.credentials[:stripe][:api_key]
    @customer = Stripe::Customer.retrieve(stripe_customer_id)
    mail(subject: "New stripe customer created.")
  end

  def customer_subscription_created_notification(subscription_id, user_id)
    Stripe.api_key = Rails.application.credentials[:stripe][:api_key]
    @subscription = Stripe::Subscription.retrieve(subscription_id)
    @user = User.find(user_id)
    mail(subject: "Congratulations! We have a new customer subscription.")
  end

  def customer_subscription_deleted_notification(subscription_id, user_id)
    Stripe.api_key = Rails.application.credentials[:stripe][:api_key]
    @subscription = Stripe::Subscription.retrieve(subscription_id)
    @user = User.find(user_id)
    mail(subject: "Churn update - Cheer subscription deleted.")
  end

  def invoice_paid_notification(invoice_id)
    Stripe.api_key = Rails.application.credentials[:stripe][:api_key]
    @invoice = Stripe::Invoice.retrieve(invoice_id)
    mail(subject: "You got paid!")
  end

  def invoice_payment_action_required_notification(invoice_id)
    Stripe.api_key = Rails.application.credentials[:stripe][:api_key]
    @invoice = Stripe::Invoice.retrieve(invoice_id)
    mail(subject: "You got paid!")
  end

  def invoice_payment_failed_notification(invoice_id)
    Stripe.api_key = Rails.application.credentials[:stripe][:api_key]
    @invoice = Stripe::Invoice.retrieve(invoice_id)
    mail(subject: "You got paid!")
  end
end
