class DashboardController < ApplicationController
  helper DashboardHelper
  def home
    @historical_cashflow_chart_data = current_user.historical_cashflow.chart_data('monthly')
  end

  def index
    @start_date, @end_date = parse_params(params)
    @time_period = params[:period] || 'this_month'
    @cashflow = current_user.cashflow(@start_date, @end_date)
    @spend_by_categories = current_user.spend_by_categories(@start_date, @end_date)
    @earning_transactions = current_user.money_in_by_categories(@start_date, @end_date)
    @transactions = current_user.transactions.occured_between(@start_date, @end_date)
  end

  private

  def parse_params(params)
    start_date = Time.zone.now.beginning_of_month
    end_date = Time.zone.now
    start_date = Time.zone.parse(params[:start]) if params[:start]
    end_date = Time.zone.parse(params[:end]) if params[:end]
    return start_date, end_date
  end
end
