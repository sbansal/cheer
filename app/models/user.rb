class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  has_many :login_items, dependent: :destroy
  has_many :bank_accounts, dependent: :destroy
  has_many :transactions, ->{ order(:occured_at => 'DESC') }, dependent: :destroy
  
  def has_no_posts?
    true
  end

 def friendly_name
   full_name.split(' ')&.first
 end
 
 def accounts_count
   login_items.map { |item| item.bank_accounts.count }.sum
 end
 
 def total_money_in(start_date=(Time.zone.now.beginning_of_month - 1.month), end_date=Time.zone.now)
   login_items.map { |item| item.bank_accounts.inject(0) { |sum, account| account.total_money_in(start_date, end_date) + sum } }.sum
 end
 
 def total_money_out(start_date=(Time.zone.now.beginning_of_month - 1.month), end_date=Time.zone.now)
   login_items.map { |item| item.bank_accounts.inject(0) { |sum, account| account.total_money_out(start_date, end_date) + sum } }.sum
 end
 
 def total_savings
   total_money_in.abs - total_money_out.abs
 end
 
 def process_recurring_transactions
   bank_accounts.map { |account| [account.id, account.recurring_transactions] }.to_h
 end
 
 def subscriptions
   bank_accounts.map { |account| account.subscriptions }.flatten
 end
 
 def essential_transactions_by_categories(start_date=(Time.zone.now.beginning_of_month - 1.month), end_date=Time.zone.now)
   transactions.occured_between(start_date, end_date).includes(:category).essential.group_by { |tx| tx.category.descriptive_name }.map {
     |descriptive_name, transactions| CategorizedTransaction.new(descriptive_name, transactions)
   }.sort_by(&:total_spend).reverse
 end
 
 def non_essential_transactions_by_categories(start_date=(Time.zone.now.beginning_of_month - 1.month), end_date=Time.zone.now)
   transactions.occured_between(start_date, end_date).includes(:category).non_essential.group_by { |tx| tx.category.descriptive_name }.map {
     |descriptive_name, transactions| CategorizedTransaction.new(descriptive_name, transactions)
   }.sort_by(&:total_spend).reverse
 end
end
