class DashboardController < ApplicationController
  helper DashboardHelper
  def home
    @historical_cashflow_chart_data = current_user.historical_cashflow.chart_data('monthly')
  end
  
  def index
    @start_date = Time.zone.parse(params[:start]) || Time.zone.now.beginning_of_month
    @end_date = Time.zone.parse(params[:end]) || Time.zone.now
    @cashflow = current_user.historical_cashflow.monthly_trends.first[:cashflow]
    @spend_by_category = current_user.non_essential_transactions_by_categories(@start_date, @end_date)
    @essential_transactions_by_categories = current_user.essential_transactions_by_categories(@start_date, @end_date)
    @transactions = current_user.transactions.occured_between(@start_date, @end_date).group_by(&:occured_at)
  end
end
