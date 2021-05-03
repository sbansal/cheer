class Stat < ApplicationRecord
  belongs_to :account

  NET_WORTH_STAT = 'net_worth'
  ASSETS_STAT = 'assets'
  LIABILITIES_STAT = 'liabilities'
  CASH_STAT = 'cash'
  INVESTMENTS_STAT = 'investments'
  
  WEEKLY = 'weekly'
  MONTHLY = 'monthly'
  QUARTERLY = 'quarterly'
  YEARLY = 'yearly'
  ALL = 'all'

  SUPPORTED_STATS = {
    NET_WORTH_STAT => 'Net Worth',
    ASSETS_STAT => 'Assets',
    LIABILITIES_STAT => 'Liabilities',
    CASH_STAT => 'Cash',
    INVESTMENTS_STAT => 'Investments',
  }
  
  SUPPORTED_PERIODS = {
    WEEKLY => 'Past Week',
    MONTHLY => 'Past Month',
    QUARTERLY => 'Past 3 Months',
    YEARLY => 'Past Year',
    ALL => 'All Time',
  }
end
