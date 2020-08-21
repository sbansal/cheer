class Account < ApplicationRecord
  has_many :users, ->{ order(:created_at => 'ASC') }, dependent: :destroy
  has_many :transactions, through: :users
  has_many :login_items, through: :users
  has_many :bank_accounts, through: :users
  has_many :subscriptions, through: :users

  def money_in_by_categories(start_date, end_date)
    transactions.occured_between(start_date, end_date).includes(:category).filter(&:non_charge?).group_by {
      |tx| tx.category.descriptive_name
    }.map {
      |descriptive_name, transactions| CategorizedTransaction.new(descriptive_name, transactions)
    }.sort_by(&:total_spend)
  end

  def spend_by_categories(start_date, end_date)
    essentials_by_categories = transactions.occured_between(start_date, end_date).includes(:category).essential.filter(&:charge?).group_by { |tx| tx.category.descriptive_name }.map {
      |descriptive_name, transactions| CategorizedTransaction.new(descriptive_name, transactions)
    }.sort_by(&:total_spend).reverse
    essentials_total = essentials_by_categories.map { |spend| spend.total_spend }.sum

    extras_by_categories = transactions.occured_between(start_date, end_date).includes(:category).non_essential.filter(&:charge?).group_by { |tx| tx.category.descriptive_name }.map {
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
      transactions.occured_between(start_date, end_date).with_category_description(descriptive_name).filter(&:non_charge?)
    else
      if args[:essential] == 'true'
        transactions.occured_between(start_date, end_date).essential.with_category_description(descriptive_name).filter(&:charge?)
      else
        transactions.occured_between(start_date, end_date).non_essential.with_category_description(descriptive_name).filter(&:charge?)
      end
    end
  end
end
