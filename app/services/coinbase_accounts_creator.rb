require 'coinbase/wallet'
class CoinbaseAccountsCreator < ApplicationService
  attr_reader :login_item
  def initialize(login_item)
    @client = CoinbaseClient.call(login_item.oauth_access_token, login_item.oauth_refresh_token)
    @login_item = login_item
  end

  def call
    begin
      accounts = fetch_accounts_data
      result = BankAccount.upsert_all(
        accounts.compact,
        unique_by: [:coinbase_account_id],
      )
      Rails.logger.info("Total coinbase accounts actually saved to DB=#{result.length}")
      result
    rescue => e
      Rails.logger.error("Upsert failed for #{accounts.length} accounts. Exception=#{e}")
    end
  end

  private

  def fetch_accounts_data
    accounts = @client.accounts
    # fetch the primary account and anything with a balance greter than zero
    accounts = accounts.select { |account| account['primary'] == true || account['balance']['amount'].to_i != 0 }
    accounts.map do |account|
      {
        'name' => account['name'],
        'official_name' => account['name'],
        'account_type' => BankAccount::CRYPTO,
        'account_subtype' => account['type'] || 'wallet',
        'coinbase_account_id' => account['id'],
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

end