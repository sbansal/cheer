class StripeWebhookEventProcessor < ApplicationService
  class StripeWebhookEventError < StandardError; end

  def initialize(request)
    @payload = request.body.read
    @sig_header = request.env['HTTP_STRIPE_SIGNATURE']
  end

  require 'stripe'
  def call
    Stripe.api_key = Rails.application.credentials[:stripe][:api_key]
    endpoint_secret = Rails.application.credentials[:stripe][:endpoint_secret]
    begin
      event = Stripe::Webhook.construct_event(@payload, @sig_header, endpoint_secret)
      process_event(event)
    rescue JSON::ParserError => e
      Rails.logger.error("Invalid payload received from stripe webhook event, payload: {#{@payload}}")
      return false
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error("Signature verification failed for stripe webhook event, payload: {#{@payload}}")
      return false
    rescue StripeWebhookEventError => e
      Rails.logger.error(e)
      return false
    end
  end

  private

  def process_event(event)
    Rails.logger.info("[StripeWebhookEventProcessor] Processing event - #{event}")
    case event.type
    when 'customer.created'
      customer = event.data.object
      user = User.find_by(email: customer.email)
      if user
        user.update(stripe_customer_id: customer.id)
      end
      return true
    when 'customer.deleted'
      customer = event.data.object
      user = User.find_by(stripe_customer_id: customer.id)
      if user
        user.update(stripe_customer_id: nil)
      end
      return true
    when 'customer.subscription.created'
      subscription = event.data.object
      user = User.find_by(stripe_customer_id: subscription.customer)
      if user
        user.company.update_subscription_details(subscription)
        GenericMailer.customer_subscription_created_notification(user.id).deliver_later
      end
      return true
    when 'customer.subscription.updated'
      subscription = event.data.object
      user = User.find_by(stripe_customer_id: subscription.customer)
      if user
        user.company.update_subscription_details(subscription)
      end
      return true
    when 'customer.subscription.deleted'
      subscription = event.data.object
      user = User.find_by(stripe_customer_id: subscription.customer)
      if user
        user.company.update_subscription_details(subscription)
        GenericMailer.customer_subscription_deleted_notification(subscription.id, user.id).deliver_later
      end
      return true
    else
      Rails.logger.info("Unhandled event type: #{event.type} ")
      return true
    end
  end
end
