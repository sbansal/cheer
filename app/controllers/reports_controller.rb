class ReportsController < ApplicationController
  def index
    params[:period] ||= Date.today.strftime('%b %Y')
    @period = params[:period]
    @start_date = params[:start_date] || Date.today.beginning_of_month
    @end_date = params[:end_date] || Date.today
    @transactions = current_company.transactions.occured_between(@start_date, @end_date).includes(:category)
    unless current_user.new_company?
      @income_transactions = @transactions.credits
      @income_transactions_by_category = @transactions.credits.group_by(&:category).map {
        |category, transactions| Transaction::CategorizedTransaction.new(category, transactions)
      }.sort_by { |item| item.total_spend }
      @expense_transactions_by_category = @transactions.debits.group_by(&:category).map {
        |category, transactions| Transaction::CategorizedTransaction.new(category, transactions)
      }.sort_by { |item| item.total_spend }
      @investment_transactions_by_category = @transactions.investments.group_by(&:category).map {
        |category, transactions| Transaction::CategorizedTransaction.new(category, transactions)
      }.sort_by { |item| item.total_spend }
      @income_stat = @income_transactions.sum(:amount).abs
      @expenses_transactions = @transactions.debits
      @expenses_stat = @transactions.debits.sum(:amount).abs
      @investments = @transactions.investments
      @investments_stat = @investments.sum(:amount).abs
      @savings_stat = @income_stat - @expenses_stat - @investments_stat
      @cash_stat = current_company.stats.find_by(name: Stat::CASH_STAT).current_value
      @net_worth_stat = current_company.stats.find_by(name: Stat::NET_WORTH_STAT).current_value
      @assets_stat = current_company.stats.find_by(name: Stat::ASSETS_STAT).current_value
      @liabilities_stat = current_company.stats.find_by(name: Stat::LIABILITIES_STAT).current_value
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
end
