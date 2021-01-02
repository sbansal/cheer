class Account < ApplicationRecord
  has_many :users, ->{ order(:created_at => 'ASC') }, dependent: :destroy
  has_many :transactions, through: :users
  has_many :login_items, through: :users
  has_many :bank_accounts, through: :users
  has_many :subscriptions, through: :users

  def money_in_by_categories(start_date, end_date)
    #TODO - Revisit the use of bank accounts here.
    txs = bank_accounts.map { |ba| ba.money_in_transactions(start_date, end_date) }.flatten
    txs.group_by { |tx| tx.category.descriptive_name }.map {
      |descriptive_name, transactions| CategorizedTransaction.new(descriptive_name, transactions)
    }.sort_by(&:total_spend)
  end

  def spend_by_categories(start_date, end_date)
    #TODO - Revisit the use of bank accounts here.
    essential_txs = bank_accounts.map { |ba| ba.essential_money_out_transactions(start_date, end_date) }.flatten
    essentials_by_categories = essential_txs.group_by { |tx| tx.category.descriptive_name }.map {
      |descriptive_name, transactions| CategorizedTransaction.new(descriptive_name, transactions)
    }.sort_by(&:total_spend).reverse
    essentials_total = essentials_by_categories.map { |spend| spend.total_spend }.sum

    non_essential_txs = bank_accounts.map { |ba| ba.non_essential_money_out_transactions(start_date, end_date) }.flatten
    extras_by_categories = non_essential_txs.group_by { |tx| tx.category.descriptive_name }.map {
      |descriptive_name, transactions| CategorizedTransaction.new(descriptive_name, transactions)
    }.sort_by(&:total_spend).reverse
    extras_total = extras_by_categories.map { |spend| spend.total_spend }.sum

    {
      essentials_total: essentials_total,
      essentials_by_categories: essentials_by_categories,
      extras_total: extras_total,
      extras_by_categories: extras_by_categories,
    }
  end

  def cashflow(start_date=Time.zone.now.beginning_of_month, end_date=Time.zone.now)
    Cashflow.new(start_date, end_date, transactions.includes(:category))
  end

  def find_transactions(start_date, end_date, args={})
    descriptive_name = args[:category_desc]
    if args[:cashflow_type] == 'money_in'
      transactions.includes([:category]).occured_between(start_date, end_date).with_category_description(descriptive_name).filter(&:credit?)
    else
      if args[:essential] == 'true'
        transactions.includes([:category]).occured_between(start_date, end_date).essential.with_category_description(descriptive_name).filter(&:debit?)
      else
        transactions.includes([:category]).occured_between(start_date, end_date).non_essential.with_category_description(descriptive_name).filter(&:debit?)
      end
    end
  end

  def total_assets
    users.map { |user| user.total_assets }.sum
  end

  def total_liabilities
    users.map { |user| user.total_liabilities }.sum
  end

  def net_worth
    users.map { |user| user.net_worth }.sum
  end

  def assets_trend
    aggregated_daily_balances_for_accounts(bank_accounts.assets.includes([:balances]))
  end

  def liabilities_trend
    aggregated_daily_balances_for_accounts(bank_accounts.liabilities.includes([:balances]))
  end

  private

  def aggregated_daily_balances_for_accounts(accounts)
    accounts.map(&:historical_balances).inject({}) {|hash, item| hash.merge(item) {|k, o, n| o + n} }.sort.to_h
  end
end
