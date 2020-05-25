class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  has_many :login_items, dependent: :destroy
  has_many :bank_accounts, dependent: :destroy
  has_many :transactions, ->{ order(:occured_at => 'DESC') }, dependent: :destroy

  def friendly_name
    full_name.split(' ')&.first
  end
 
 def cashflow(start_date=Time.zone.now.beginning_of_month, end_date=Time.zone.now)
   Cashflow.new(start_date, end_date, transactions.includes(:category))
 end
 
 def historical_cashflow(start_date=Time.zone.now.beginning_of_year, end_date=Time.zone.now)
   HistoricalCashflow.new(start_date, end_date, transactions.includes(:category))
 end
 
 def accounts_count
   login_items.map { |item| item.bank_accounts.count }.sum
 end
 
 def process_recurring_transactions
   bank_accounts.map { |account| [account.id, account.recurring_transactions] }.to_h
 end
 
 def subscriptions
   bank_accounts.map { |account| account.subscriptions }.flatten
 end
 
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
 
 def this_month_transactions
   transactions.occured_between(Time.zone.now.beginning_of_month, Time.zone.now).includes(:category)
 end
 
 def find_transactions(start_date, end_date, args={})
   descriptive_name = args[:category_desc]
   if args[:cashflow_type] == 'money_in'
     transactions.occured_between(start_date, end_date).includes([:category, :bank_account]).with_category_description(descriptive_name).filter(&:non_charge?)
   else
     if args[:essential] == 'true'
       transactions.occured_between(start_date, end_date).includes([:category, :bank_account]).essential.with_category_description(descriptive_name).filter(&:charge?)
     else
       transactions.occured_between(start_date, end_date).includes([:category, :bank_account]).non_essential.with_category_description(descriptive_name).filter(&:charge?)
     end
   end
 end
end
