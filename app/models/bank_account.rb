class BankAccount < ApplicationRecord
  has_many :transactions, ->{ order(:occured_at => 'DESC') }, dependent: :destroy
  belongs_to :user
  belongs_to :login_item
  has_many :subscriptions, dependent: :destroy
  
  def self.create_accounts_from_json(accounts_json_array, login_item_id, user_id)
    banks_accounts = accounts_json_array.map do |account_json|
      {
        plaid_account_id: account_json.account_id,
        name: account_json.name,
        official_name: account_json.official_name,
        account_type: account_json.type,
        account_subtype: account_json.subtype,
        mask: account_json.mask,
        balance_available: account_json.balances.available,
        balance_limit: account_json.balances.limit,
        balance_currency_code: account_json.balances.iso_currency_code || account_json.balances.unofficial_currency_code, 
        login_item_id: login_item_id,
        user_id: user_id,
      }
    end
    create!(banks_accounts)
  end
  
  def descriptive_name
    (official_name || name) + " - xxxx" + mask
  end

  def total_money_out(start_date=(Time.zone.now.beginning_of_month), end_date=Time.zone.now)
    transactions.includes(:category).occured_between(start_date, end_date).map { 
      |tx| tx.amount > 0 && !tx.category.internal_account_transfer? ? tx.amount : 0 
    }.sum.abs
  end
  
  def total_money_in(start_date=(Time.zone.now.beginning_of_month), end_date=Time.zone.now)
    transactions.occured_between(start_date, end_date).map { |tx| tx.amount < 0 ? tx.amount : 0 }.sum.abs
  end
  
  def recurring_transactions
    transactions_hash = transactions.select(&:payment?).group_by { |tx| tx.description + tx.amount.to_s }
    recurring_transactions = [] 
    transactions_hash.each do |key, transactions|
      if transactions.count > 1
        dates = transactions.map(&:occured_at)
        frequencies = dates.filter_map.with_index do |date, i|
          (dates[i] - dates[i+1]).to_i unless dates[i+1].nil?
        end
        user_subscription = self.subscriptions.build(user_id: user.id).with_frequency(frequencies.uniq.sort)
        if user_subscription.frequency?
          user_subscription.last_transaction = transactions.first
          user_subscription.save!
          recurring_transactions << user_subscription
        end
      end
    end
    recurring_transactions
  end
  
  def balance
    balance_available || balance_limit || 'N/A'
  end
end
