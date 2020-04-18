class DashboardController < ApplicationController
  def home
  end
  
  def index
    @login_items = current_user.login_items
  end
end
