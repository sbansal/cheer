class EventsController < ApplicationController
  skip_before_action :authenticate_user!, :only => [:login_item_callback]
  protect_from_forgery except: :login_item_callback

  def login_item_callback
    callback_processed = PlaidWebhookEventProcessor.call(request.headers['Plaid-Verification'], request.raw_post)
    if callback_processed
      head :accepted
    else
      head :bad_request
    end
  end

  def coinbase_callback
    Rails.logger.info("Notification from coinbase")
    head :accepted
  end
end
