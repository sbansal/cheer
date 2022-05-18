class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:login_item_callback, :stripe_callback]
  protect_from_forgery except: [:login_item_callback, :stripe_callback]
  skip_before_action :check_subscription_active?, only: [:login_item_callback, :stripe_callback]

  def login_item_callback
    callback_processed = PlaidWebhookEventProcessor.call(request.headers['Plaid-Verification'], request.raw_post)
    if callback_processed
      head :accepted
    else
      head :bad_request
    end
  end

  def stripe_callback
    callback_processed = StripeWebhookEventProcessor.call(request)
    if callback_processed
      head :accepted
    else
      head :bad_request
    end
  end
end
