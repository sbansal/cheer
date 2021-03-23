class BankAccount < ApplicationRecord
  has_many :transactions, ->{ order(:occured_at => 'DESC') }, dependent: :destroy
  belongs_to :user
  belongs_to :login_item, optional: true
  belongs_to :institution, optional: true
  has_many :subscriptions, dependent: :destroy
  has_many :balances, ->{ order(:created_at => 'DESC') }, dependent: :destroy

  scope :assets, -> { where(account_type: [DEPOSITORY_TYPE, INVESTMENT_TYPE, REAL_ESTATE, COLLECTIBLE, CASH, OTHER_ASSET]) }
  scope :liabilities, -> { where(account_type: [LOAN_TYPE, CREDIT_TYPE, OTHER_LIABILITY]) }

  INVESTMENT_TYPE = "investment"
  LOAN_TYPE = "loan"
  DEPOSITORY_TYPE = "depository"
  CREDIT_TYPE = "credit"
  REAL_ESTATE = "real estate"
  COLLECTIBLE = "collectible"
  CASH = "cash"
  OTHER_ASSET = "other asset"
  OTHER_LIABILITY = "other liability"
  BROKERAGE = "brokerage"

  def self.create_accounts_from_json(accounts_json_array, login_item_id, user_id, institution_id)
    banks_accounts = accounts_json_array.filter_map do |account_json|
      user_account = User.find(user_id)&.account
      existing_bank_accounts = user_account.bank_accounts.where(
        name: account_json[:name],
        mask: account_json[:mask],
        institution_id: institution_id,
      )
      if existing_bank_accounts.empty?
        {
          plaid_account_id: account_json[:account_id],
          name: account_json[:name],
          official_name: account_json[:official_name],
          account_type: account_json[:type],
          account_subtype: account_json[:subtype],
          mask: account_json[:mask],
          balance_available: account_json[:balances][:available],
          balance_limit: account_json[:balances][:limit],
          current_balance: account_json[:balances][:current],
          current_balance_updated_at: Time.zone.now,
          balance_currency_code: account_json[:balances][:iso_currency_code] || account_json[:balances][:unofficial_currency_code],
          login_item_id: login_item_id,
          user_id: user_id,
          institution_id: institution_id,
        }
      else
        Rails.logger.warn("Account already exists for account data: #{account_json}")
        next
      end
    end
    create!(banks_accounts)
  end

  def self.update_balances(accounts_json)
    accounts_json.each do |account_json|
      begin
        plaid_account_id = account_json[:account_id]
        bank_account = BankAccount.find_by!(plaid_account_id: plaid_account_id)
        balance_available = account_json[:balances][:available]
        balance_limit = account_json[:balances][:limit]
        current_balance = account_json[:balances][:current]
        balance_currency_code = account_json[:balances][:iso_currency_code]
        # cache balance on accounts
        bank_account.update(
          balance_available: balance_available,
          balance_limit: balance_limit,
          balance_currency_code: balance_currency_code,
          current_balance: current_balance,
          current_balance_updated_at: Time.zone.now,
        )
        # create new balance
        bank_account.balances.create(
          current: current_balance,
          available: balance_available,
          limit: balance_limit,
          user_id: bank_account.user_id,
          currency_code: balance_currency_code,
        )
      rescue => e
        Rails.logger.error(
          "Unable to update balance plaid_account_id:#{plaid_account_id} with payload: #{account_json}, exception - #{e}"
        )
        next
      end
    end
  end

  def create_from_params(params)
    self.name = params['name']
    self.official_name = params['name']
    self.account_type = params['account_type']
    self.account_subtype = params['account_subtype']
    self.classification = params['account_category']
    self.balance_currency_code = 'USD'
    current_value = sanitize_balance(params['balance'])
    self.current_balance = current_value
    self.current_balance_updated_at = Time.zone.now
    self.save
    unless params['balance'].nil?
      self.balances.create(current: current_value, currency_code: 'USD', user_id: self.user_id, bank_account_id: self)
    end
    self
  end

  def update_from_params(params)
    current_value = sanitize_balance(params['current_balance'])
    self.current_balance = current_value
    self.current_balance_updated_at = Time.zone.now
    self.balances.build(current: current_value, currency_code: 'USD', user_id: self.user_id)
    self.save
  end

  def descriptive_name
    if mask
      display_name + " - " + mask
    else
      display_name
    end
  end

  def display_name
    official_name || name
  end

  def asset?
    [DEPOSITORY_TYPE, INVESTMENT_TYPE, REAL_ESTATE, COLLECTIBLE, CASH, OTHER_ASSET].include?(account_type)
  end

  def real_estate?
    [REAL_ESTATE].include?(account_type)
  end

  def liability?
    [LOAN_TYPE, CREDIT_TYPE, OTHER_LIABILITY].include?(account_type)
  end

  def depository_account?
    account_type == DEPOSITORY_TYPE
  end

  def manually_tracked?
    institution.nil?
  end

  def create_recurring_transactions
    transactions_hash = transactions.debits.order('occured_at asc').group_by {
      |tx| "#{tx.custom_description}_#{tx.amount.to_s}"
    }
    recurring_transactions = []
    transactions_hash.each do |key, transactions|
      if transactions.count > 1
        dates = transactions.map(&:occured_at)
        frequencies = dates.filter_map.with_index do |date, i|
          (dates[i] - dates[i+1]).to_i unless dates[i+1].nil?
        end
        last_transaction = transactions.first
        user_subscription = self.subscriptions.find_or_initialize_by(
          user_id: user_id,
          description: last_transaction.custom_description,
          amount: last_transaction.amount,
        )
        user_subscription = user_subscription.with_frequency(frequencies)
        if user_subscription.frequency?
          user_subscription.last_transaction = last_transaction
          user_subscription.update_state
          begin
            user_subscription.save!
            recurring_transactions << user_subscription
          rescue => e
            Rails.logger.error("Unable to create subscription with params: #{user_subscription.to_json}. Exception=#{e}")
          end
        end
      end
    end
    recurring_transactions
  end

  def last_balance
    balances&.first
  end

  # This method returns a historical snapshot of the daily balances for an account
  def historical_balances(end_datetime=Time.zone.now.beginning_of_day.to_datetime)
    balance_by_created = balances.reverse.map {|balance| [balance.created_at.to_datetime.beginning_of_day, balance.current]}.to_h
    unless balance_by_created.empty?
      last_value = nil
      balance_by_created.keys.first.upto(end_datetime).each do |ref_datetime|
        if balance_by_created[ref_datetime]
          last_value = balance_by_created[ref_datetime]
        else
          balance_by_created[ref_datetime] = last_value
        end
      end
    end
    balance_by_created.sort.to_h
  end

  def self.liquid_accounts
    where('account_type in (?) or account_subtype in (?)', [CASH, DEPOSITORY_TYPE], [BROKERAGE])
  end

  def self.illiquid_accounts
    where('account_type in (?) and account_subtype not in (?)', [INVESTMENT_TYPE, REAL_ESTATE, COLLECTIBLE, OTHER_ASSET], [BROKERAGE])
  end

  private

  def sanitize_balance(balance)
    balance&.gsub(',',"")&.gsub('$',"") || 0
  end

end
