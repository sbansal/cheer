class DashboardController < ApplicationController
  helper DashboardHelper
  def home
  end
  
  def index
    @spend_by_category = current_user.non_essential_transactions_by_categories
    @essential_transactions_by_categories = current_user.essential_transactions_by_categories
  end
end
