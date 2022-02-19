class DashboardController < ApplicationController
  helper DashboardHelper
  def home
    @historical_cashflow_chart_data = current_user.historical_cashflow.chart_data('monthly')
  end

  def cashflow
    @period = params[:period] || Stat::WEEKLY
    @period_description = Stat::SUPPORTED_PERIODS[@period]

    @net_worth_stat = current_account.stats.find_by(name: Stat::NET_WORTH_STAT)
    @net_worth_change = @net_worth_stat.last_change_data[@period]
    @assets_stat = current_account.stats.find_by(name: Stat::ASSETS_STAT)
    @assets_change = @assets_stat.last_change_data[@period]
    @liabilities_stat = current_account.stats.find_by(name: Stat::LIABILITIES_STAT)
    @liabilities_change = @liabilities_stat.last_change_data[@period]
    @cash_stat = current_account.stats.find_by(name: Stat::CASH_STAT)
    @cash_change = @cash_stat.last_change_data[@period]
    @investments_stat = current_account.stats.find_by(name: Stat::INVESTMENTS_STAT)
    @investments_change = @investments_stat.last_change_data[@period]

    @assets_count = current_account.bank_accounts.assets.count
    @cash_asset_accounts = current_account.bank_accounts.includes([:institution]).assets.liquid_accounts.sort_by {
      |item| item.current_balance
    }.reverse
    @non_cash_asset_accounts = current_account.bank_accounts.includes([:institution]).assets.illiquid_accounts.sort_by {
      |item| item.current_balance
    }.reverse
    @liability_accounts = current_account.bank_accounts.includes([:institution]).liabilities.sort_by {
      |item| item.current_balance
    }.reverse
  end

  def income_expense
    @period = params[:period] || Stat::WEEKLY
    @period_description = Stat::SUPPORTED_PERIODS[@period]

    @income_stat = compute_stat_value_for_period(Stat::INCOME_STAT, @period)
    @expenses_stat = compute_stat_value_for_period(Stat::EXPENSES_STAT, @period)
    @savings_stat = compute_stat_value_for_period(Stat::SAVINGS_STAT, @period)
    @essential_expenses_stat = compute_stat_value_for_period(Stat::ESSENTIAL_EXPENSES_STAT, @period)
    @non_essential_expenses_stat = compute_stat_value_for_period(Stat::NON_ESSENTIAL_EXPENSES_STAT, @period)
  end

  private

  def parse_params(params)
    start_date = params[:start].blank? ? Time.zone.now.beginning_of_month : Time.zone.parse(params[:start])
    end_date = params[:end].blank? ? Time.zone.now : Time.zone.parse(params[:end])
    return start_date, end_date
  end

  def compute_stat_value_for_period(stat, period)
    if value_over_time_data = current_account.stats.find_by(name: stat)&.value_over_time_data
      value_over_time_data[period]
    else
      0
    end
  end
end
