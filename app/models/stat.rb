class Stat < ApplicationRecord
  belongs_to :account

  NET_WORTH_STAT = 'net_worth'
  ASSETS_STAT = 'assets'
  LIABILITIES_STAT = 'liabilities'
  CASH_STAT = 'cash'
  INVESTMENTS_STAT = 'investments'
  INCOME_STAT = 'income'
  EXPENSES_STAT = 'expenses'
  SAVINGS_STAT = 'savings'
  ESSENTIAL_EXPENSES_STAT = 'essential_expenses'
  NON_ESSENTIAL_EXPENSES_STAT = 'non_essential_expenses'

  WEEKLY = 'weekly'
  MONTHLY = 'monthly'
  QUARTERLY = 'quarterly'
  YEARLY = 'yearly'
  ALL = 'all'
  THIS_MONTH = 'this_month'
  LAST_MONTH = 'last_month'

  SUPPORTED_STATS = {
    NET_WORTH_STAT => 'Net Worth',
    ASSETS_STAT => 'Assets',
    LIABILITIES_STAT => 'Liabilities',
    CASH_STAT => 'Cash',
    INVESTMENTS_STAT => 'Investments',
    INCOME_STAT => 'Income',
    EXPENSES_STAT => 'Expenses',
    SAVINGS_STAT => 'Savings',
    ESSENTIAL_EXPENSES_STAT => 'Essential Expenses',
    NON_ESSENTIAL_EXPENSES_STAT => 'Non-essential Expenses',
  }

  SUPPORTED_PERIODS = {
    WEEKLY => 'Past Week',
    MONTHLY => 'Past Month',
    QUARTERLY => 'Past 3 Months',
    YEARLY => 'Past Year',
    ALL => 'All Time',
    THIS_MONTH => 'This Month',
    LAST_MONTH => 'Last Month',
  }

  def fetch_historical_trend_since(date)
    self.historical_trend_data.filter { |key, value| Date.parse(key) >= date }.map do |key, value|
      [Date.parse(key).to_time.utc.to_i*1000, value]
    end.to_h
  end
end
