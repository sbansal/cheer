class DashboardController < ApplicationController
  helper DashboardHelper
  def home
    @historical_cashflow_chart_data = current_user.historical_cashflow.chart_data('monthly')
  end

  def index
    @start_date, @end_date = parse_params(params)
    @time_period = params[:period] || 'this_month'
    @cashflow = current_account.cashflow(@start_date, @end_date)
    @spend_by_categories = current_account.spend_by_categories(@start_date, @end_date)
    @earning_transactions = current_account.money_in_by_categories(@start_date, @end_date)
    @transactions = current_account.transactions.includes([:bank_account, :category]).occured_between(@start_date, @end_date)
  end

  def transactions
    @start_date = Time.zone.parse(params[:start])
    @end_date = Time.zone.parse(params[:end])
    @transactions = current_account.find_transactions(@start_date, @end_date, params)
    respond_to do |format|
      format.js
    end
  end

  def cashflow
    @asset_accounts = current_account.bank_accounts.includes([login_item: [:institution]]).assets.sort_by { |item| item.balance }.reverse
    @liability_accounts = current_account.bank_accounts.includes([login_item: [:institution]]).liabilities.sort_by { |item| item.balance }.reverse
    @assets_trend = current_account.assets_trend
    @liabilities_trend = current_account.liabilities_trend
  end

  def income_expense
    @start_date, @end_date = parse_params(params)
    @time_period = params[:period] || 'this_month'
    @cashflow = current_account.cashflow(@start_date, @end_date)
    @spend_by_categories = current_account.spend_by_categories(@start_date, @end_date)
    @earning_transactions = current_account.money_in_by_categories(@start_date, @end_date)
    @transactions = current_account.transactions.includes([:bank_account, :category]).occured_between(@start_date, @end_date)
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
