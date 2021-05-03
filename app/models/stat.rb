class Stat < ApplicationRecord
  belongs_to :account

  NET_WORTH_STAT = 'net_worth'
  ASSETS_STAT = 'assets'
  LIABILITIES_STAT = 'liabilities'
  CASH_STAT = 'cash'
  INVESTMENTS_STAT = 'investments'

  SUPPORTED_STATS = {
    NET_WORTH_STAT => 'Net Worth',
    ASSETS_STAT => 'Assets',
    LIABILITIES_STAT => 'Liabilities',
    CASH_STAT => 'Cash',
    INVESTMENTS_STAT => 'Investments',
  }
end
