class DashboardController < ApplicationController
  helper DashboardHelper
  def home
  end
  
  def index
    @subscriptions = current_user.subscriptions
    @spend_by_category = current_user.transactions_amount_by_top_category
  end
end
