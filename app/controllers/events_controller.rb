class EventsController < ApplicationController
  skip_before_action :authenticate_user!, :only => [:login_item_callback, :ping]
  protect_from_forgery except: :login_item_callback

  def ping
    Rails.logger.info("EventsController/ping was queried with with headers=#{request.headers.to_h}")
    render plain: 'pong', status: 200
  end

  def login_item_callback
    Rails.logger.info("Received plaid webhook with headers=#{request.headers.to_h}")
    callback_processed = PlaidWebhookEventProcessor.call(request.headers['Plaid-Verification'], request.raw_post)
    if callback_processed
      head :accepted
    else
      head :bad_request
    end
  end
end
