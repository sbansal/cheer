class Company < ApplicationRecord
  has_many :users, ->{ order(:created_at => 'ASC') }, dependent: :destroy, inverse_of: :company
  accepts_nested_attributes_for :users

  has_many :transactions, ->{ order(:occured_at => 'DESC') }, through: :users
  has_many :login_items, ->{ order(:created_at => 'DESC') }, through: :users
  has_many :bank_accounts, ->{ order(:name => 'ASC') }, through: :users
  has_many :subscriptions, ->{ order(:updated_at => 'DESC') }, through: :users
  has_many :notifications, ->{ order(:created_at => 'DESC') }, through: :users
  has_many :stats, dependent: :destroy

  def money_in_by_categories(start_date, end_date)
    txs = transactions.includes(:category).occured_between(start_date, end_date).filter(&:credit?)
    txs.group_by(&:category).map {
      |category, transactions| Transaction::CategorizedTransaction.new(category, transactions)
    }.sort_by(&:total_spend)
  end

  def spend_by_categories(start_date, end_date)
    essential_txs = transactions.where(essential: true).includes(:category).occured_between(start_date, end_date).filter(&:debit?)
    essentials_by_categories = essential_txs.group_by(&:category).map {
      |category, transactions| Transaction::CategorizedTransaction.new(category, transactions)
    }.sort_by(&:total_spend).reverse
    essentials_total = essentials_by_categories.map { |spend| spend.total_spend }.sum

    non_essential_txs = transactions.where(essential: false).includes(:category).occured_between(start_date, end_date).filter(&:debit?)
    extras_by_categories = non_essential_txs.group_by(&:category).map {
      |category, transactions| Transaction::CategorizedTransaction.new(category, transactions)
    }.sort_by(&:total_spend).reverse
    extras_total = extras_by_categories.map { |spend| spend.total_spend }.sum

    {
      essentials_total: essentials_total,
      essentials_by_categories: essentials_by_categories,
      extras_total: extras_total,
      extras_by_categories: extras_by_categories,
    }
  end

  def essential_spend_by_categories(start_date, end_date)
    essential_txs = transactions.where(essential: true).includes(:category).occured_between(start_date, end_date).filter(&:debit?)
    essentials_by_categories = essential_txs.group_by(&:category).map {
      |category, transactions| Transaction::CategorizedTransaction.new(category, transactions)
    }.sort_by(&:total_spend).reverse
    essentials_total = essentials_by_categories.map { |spend| spend.total_spend }.sum
    {
      total: essentials_total,
      transactions_by_categories: essentials_by_categories,
    }
  end

  def non_essential_spend_by_categories(start_date, end_date)
    non_essential_txs = transactions.where(essential: false).includes(:category).occured_between(start_date, end_date).filter(&:debit?)
    non_essential_txs_by_categories = non_essential_txs.group_by(&:category).map {
      |category, transactions| Transaction::CategorizedTransaction.new(category, transactions)
    }.sort_by(&:total_spend).reverse
    non_essential_total = non_essential_txs_by_categories.map { |spend| spend.total_spend }.sum
    {
      total: non_essential_total,
      transactions_by_categories: non_essential_txs_by_categories,
    }
  end

  def cashflow(start_date=Time.zone.now.beginning_of_month, end_date=Time.zone.now)
    Cashflow.new(start_date, end_date, transactions.includes(:category))
  end

  def total_cash_assets
    bank_accounts.assets.liquid_accounts.sum(:current_balance)
  end

  def total_non_cash_assets
    bank_accounts.assets.illiquid_accounts.sum(:current_balance)
  end

  def total_assets
    bank_accounts.assets.sum(:current_balance)
  end

  def total_liabilities
    bank_accounts.liabilities.sum(:current_balance)
  end

  def net_worth
    total_assets - total_liabilities
  end

  def total_investments(start_date=Time.zone.now.beginning_of_month, end_date=Time.zone.now)
    transactions.occured_between(start_date, end_date).investments.sum(:amount)
  end

  def assets_trend
    aggregated_daily_balances_for_accounts(bank_accounts.assets.includes([:balances]))
  end

  def liabilities_trend
    aggregated_daily_balances_for_accounts(bank_accounts.liabilities.includes([:balances]))
  end

  def cash_trend
    aggregated_daily_balances_for_accounts(bank_accounts.assets.liquid_accounts.includes([:balances]))
  end

  def investments_trend
    aggregated_daily_balances_for_accounts(bank_accounts.assets.illiquid_accounts.includes([:balances]))
  end

  def first_transaction_occured_at
    transactions&.last&.occured_at || self.created_at.to_date
  end
  
  PERSONAL_PRODUCT = 'PERSONAL'
  def personal_product?
    enabled_product == PERSONAL_PRODUCT
  end

  private

  def aggregated_daily_balances_for_accounts(accounts)
    accounts.map(&:historical_balances).inject({}) {|hash, item| hash.merge(item) {|k, o, n| o + n} }.sort.to_h
  end
end
