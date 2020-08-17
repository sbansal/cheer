class BankAccount < ApplicationRecord
  has_many :transactions, ->{ order(:occured_at => 'DESC') }, dependent: :destroy
  belongs_to :user
  belongs_to :login_item
  has_many :subscriptions, dependent: :destroy
  has_many :balances, ->{ order(:created_at => 'DESC') }, dependent: :destroy

  INVESTMENT_TYPE = "investment"
  LOAN_TYPE = "loan"
  DEPOSITORY_TYPE = "depository"
  CREDIT_TYPE = "credit"

  def self.create_accounts_from_json(accounts_json_array, login_item_id, user_id)
    banks_accounts = accounts_json_array.filter_map do |account_json|
      accounts = BankAccount.where(name: account_json[:name], mask: account_json[:mask])
      if accounts.count == 0
        {
          plaid_account_id: account_json[:account_id],
          name: account_json[:name],
          official_name: account_json[:official_name],
          account_type: account_json[:type],
          account_subtype: account_json[:subtype],
          mask: account_json[:mask],
          balance_available: account_json[:balances][:available],
          balance_limit: account_json[:balances][:limit],
          balance_currency_code: account_json[:balances][:iso_currency_code] || account_json[:balances][:unofficial_currency_code],
          login_item_id: login_item_id,
          user_id: user_id,
        }
      end
    end
    create!(banks_accounts)
  end

  def descriptive_name
    (official_name || name) + " - xxxx" + mask
  end

  def display_name
    official_name || name
  end

  def last_balance
    balances&.first
  end

  def investment_account?
    account_type == INVESTMENT_TYPE
  end

  def loan_account?
    account_type == LOAN_TYPE
  end

  def depository_account?
    account_type == DEPOSITORY_TYPE
  end

  def credit_account?
    account_type == CREDIT_TYPE
  end

  def total_money_out(start_date=(Time.zone.now.beginning_of_month), end_date=Time.zone.now)
    transactions.includes(:category).occured_between(start_date, end_date).map {
      |tx| tx.charge? ? tx.amount : 0
    }.sum.abs
  end

  def total_money_in(start_date=(Time.zone.now.beginning_of_month), end_date=Time.zone.now)
    transactions.occured_between(start_date, end_date).map { |tx| tx.amount < 0 ? tx.amount : 0 }.sum.abs
  end

  def recurring_transactions
    transactions_hash = transactions.select(&:charge?).group_by { |tx| tx.description + tx.amount.to_s }
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
    if depository_account?
      last_balance&.available || 'N/A'
    else
      last_balance&.current || 'N/A'
    end
  end
end
