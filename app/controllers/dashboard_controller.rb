class DashboardController < ApplicationController
  helper DashboardHelper
  def home
    @historical_cashflow_chart_data = current_user.historical_cashflow.chart_data('weekly')
  end
  
  def index
    @cashflow = current_user.historical_cashflow.monthly_trends.first[:cashflow]
    @spend_by_category = current_user.non_essential_transactions_by_categories
    @essential_transactions_by_categories = current_user.essential_transactions_by_categories
    @transactions = current_user.this_month_transactions.group_by(&:occured_at)
  end
end
