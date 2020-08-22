class SubscriptionsController < ApplicationController
  def index
    @active_subscriptions = current_account.subscriptions.select(&:active?)
    @expired_subscriptions = current_account.subscriptions.reject(&:active?)
  end
end
