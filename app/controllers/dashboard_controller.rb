class DashboardController < ApplicationController
  helper DashboardHelper
  def home
  end
  
  def index
    @login_items = current_user.login_items
  end
end
