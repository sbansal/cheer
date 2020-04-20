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
 
 def total_debits(start_date=(Time.zone.now - 1.month), end_date=Time.zone.now)
   login_items.map { |item| item.bank_accounts.inject(0) { |sum, account| account.total_debits(start_date, end_date) + sum } }.sum
 end
 
 def total_credits(start_date=(Time.zone.now - 1.month), end_date=Time.zone.now)
   login_items.map { |item| item.bank_accounts.inject(0) { |sum, account| account.total_credits(start_date, end_date) + sum } }.sum
 end
 
 def total_savings
   total_credits.abs - total_debits.abs
 end
 
 def process_recurring_transactions
   bank_accounts.map { |account| [account.id, account.recurring_transactions] }.to_h
 end
 
 def subscriptions
   bank_accounts.map { |account| account.subscriptions }.flatten
 end
end
