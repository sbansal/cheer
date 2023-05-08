class DashboardController < ApplicationController
  helper DashboardHelper
  def home
    @historical_cashflow_chart_data = current_user.historical_cashflow.chart_data('monthly')
  end

  def cashflow
    @period = params[:period] || Stat::WEEKLY
    @period_description = Stat::SUPPORTED_PERIODS[@period]
    unless current_user.new_company?
      @net_worth_stat = current_company.stats.find_by(name: Stat::NET_WORTH_STAT)
      @net_worth_change = @net_worth_stat&.last_change_data[@period]
      @assets_stat = current_company.stats.find_by(name: Stat::ASSETS_STAT)
      @assets_change = @assets_stat&.last_change_data[@period]
      @liabilities_stat = current_company.stats.find_by(name: Stat::LIABILITIES_STAT)
      @liabilities_change = @liabilities_stat&.last_change_data[@period]
      @cash_stat = current_company.stats.find_by(name: Stat::CASH_STAT)
      @cash_change = @cash_stat&.last_change_data[@period]
      @investments_stat = current_company.stats.find_by(name: Stat::INVESTMENTS_STAT)
      @investments_change = @investments_stat&.last_change_data[@period]

      @assets_count = current_company.bank_accounts.assets.count
      @cash_asset_accounts = current_company.bank_accounts.includes([:institution]).assets.liquid_accounts.sort_by {
        |item| item.current_balance
      }.reverse
      @non_cash_asset_accounts = current_company.bank_accounts.includes([:institution]).assets.illiquid_accounts.sort_by {
        |item| item.current_balance
      }.reverse
      @liability_accounts = current_company.bank_accounts.includes([:institution]).liabilities.sort_by {
        |item| item.current_balance
      }.reverse
    end
  end

  def income_expense
    @period = params[:period] || Stat::THIS_MONTH
    @period_description = Stat::SUPPORTED_PERIODS[@period]
    unless current_user.new_company?
      @income_stat = compute_stat_value_for_period(Stat::INCOME_STAT, @period)
      @expenses_stat = compute_stat_value_for_period(Stat::EXPENSES_STAT, @period)
      @savings_stat = compute_stat_value_for_period(Stat::SAVINGS_STAT, @period)
      @essential_expenses_stat = compute_stat_value_for_period(Stat::ESSENTIAL_EXPENSES_STAT, @period)
      @non_essential_expenses_stat = compute_stat_value_for_period(Stat::NON_ESSENTIAL_EXPENSES_STAT, @period)
    end
  end

  def privatefi
    @chat = current_user.chats.last
    unless @chat
      @chat = current_user.chats.create(message: 'PrivateFi chat')
      @chat.messages.create(user: current_user, content: 'Hi, I am PrivateFi. How can I help you?', query_type: Message::BOT_RESPONSE, role: :assistant)
    end
    redirect_to chat_path(@chat)
  end

  private

  def compute_stat_value_for_period(stat, period)
    if value_over_time_data = current_company.stats.find_by(name: stat)&.value_over_time_data
      value_over_time_data[period]
    else
      0
    end
  end
end
