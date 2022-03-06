require 'coinbase/wallet'
class CoinbaseAccountsCreator < ApplicationService
  attr_reader :login_item
  def initialize(login_item)
    @client = CoinbaseClient.call(login_item.provider_access_token, login_item.provider_refresh_token)
    @login_item = login_item
  end

  def call
    begin
      accounts = fetch_accounts_data
      Rails.logger.info("Accounts data - " + accounts.inspect)
      result = BankAccount.upsert_all(
        accounts.compact,
        unique_by: 'provider_item_id',
      )
      Rails.logger.info("Total coinbase accounts actually saved to DB=#{result.length}")
      result
    rescue => e
      Rails.logger.error("Upsert failed for #{accounts.length} accounts.")
      Rails.logger.error(e)
    end
  end

  private

  def fetch_accounts_data
    accounts = @client.accounts
    # fetch the primary account and anything with a balance greter than zero
    accounts = accounts.select { |acc| fetch_account_data?(acc) }.map do |account|
      {
        'name' => account['name'],
        'official_name' => account['name'],
        'account_type' => BankAccount::CRYPTO,
        'account_subtype' => account['type'] || 'wallet',
        'provider_item_id' => account['id'],
        'balance' => account['native_balance']['amount'] || 0,
        'balance_available' => account['native_balance']['amount'] || 0,
        'balance_currency_code' => account['native_balance']['currency'] || 'USD',
        'native_balance' => account['balance']['amount'] || 0,
        'native_currency' => account['balance']['currency'],
        'login_item_id' => @login_item.id,
        'institution_id' => @login_item.institution_id,
        'user_id' => @login_item.user_id,
      }
    end
    accounts
  end

  def fetch_account_data?(account)
    primary_account?(account) || has_balance?(account)
  end

  def primary_account?(account)
    account['primary']
  end

  def has_balance?(account)
    account['balance']['amount'].to_i != 0
  end

end