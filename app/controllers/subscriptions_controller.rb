class SubscriptionsController < ApplicationController
  def index
    subscriptions = current_account.subscriptions.includes([:last_transaction])
    @active_subscriptions = subscriptions.select(&:active?)
    @expired_subscriptions = subscriptions.reject(&:active?)
  end

  def show
    @subscription = current_user.subscriptions.find(params[:id])
    @aggregated_transactions = AggregatedTransactions.new(@subscription.all_transactions)
  end

  def update
    @subscription = current_user.subscriptions.find(params[:id])
    @subscription.toggle!(:active)
    subscriptions = current_account.subscriptions.includes([:last_transaction])
    @active_subscriptions = subscriptions.select(&:active?)
    @expired_subscriptions = subscriptions.reject(&:active?)
  end

end
