class DashboardController < ApplicationController
  helper DashboardHelper
  def home
  end
  
  def index
    @subscriptions = current_user.subscriptions
  end
end
