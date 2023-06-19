class Category < ApplicationRecord
  has_many :transactions
  INTERNAL_ACCOUNT_TRANSFER = 'Internal Account Transfer'
  CC_PAYMENT_PLAID_ID = '16001000'

  INTERNAL_ACCOUNT_TRANSFER_PLAID_ID = '21001000'
  INVESTMENTS_FINANCIAL_PLANNING_PLAID_ID = '18020007'
  INVESTMENTS_HOLDING_OFFICE_PLAID_ID = '18020005'
  INVESTMENTS_STOCK_BROKERS_PLAID_ID = '18020003'

  IGNORE_LIST = [
    INTERNAL_ACCOUNT_TRANSFER_PLAID_ID,
    INVESTMENTS_FINANCIAL_PLANNING_PLAID_ID,
    INVESTMENTS_HOLDING_OFFICE_PLAID_ID,
    INVESTMENTS_STOCK_BROKERS_PLAID_ID,
    CC_PAYMENT_PLAID_ID,
  ]

  INVESTMENT_CATEGORIES_LIST = [
    INVESTMENTS_FINANCIAL_PLANNING_PLAID_ID,
    INVESTMENTS_HOLDING_OFFICE_PLAID_ID,
    INVESTMENTS_STOCK_BROKERS_PLAID_ID,
  ]

  CREDIT_IGNORE_LIST = [CC_PAYMENT_PLAID_ID]

  def category_list
    hierarchy.join(', ')
  end

  def charge?
    !hierarchy.include?(INTERNAL_ACCOUNT_TRANSFER)
  end

  def ignore_for_debit?
    IGNORE_LIST.include?(plaid_category_id)
  end

  def ignore_for_credit?
    IGNORE_LIST.include?(plaid_category_id) || CREDIT_IGNORE_LIST.include?(plaid_category_id)
  end

  def cc_payment?
    plaid_category_id == CC_PAYMENT_PLAID_ID
  end

  def root_name
    hierarchy.first
  end

  def secondary_names
    hierarchy.drop(1)
  end

  def category_list_item
    arrow = "\u2192"
    arrow = arrow.encode('utf-8')
    hierarchy.join(" #{arrow} ")
  end

  def primary_name
    hierarchy.last
  end

  BANK_FEES = 'Bank Fees'
  def bank_fee_charged?
    hierarchy.include?(BANK_FEES)
  end

  PAYROLL = 'Payroll'
  def payroll?
    hierarchy.include?(PAYROLL)
  end

end
