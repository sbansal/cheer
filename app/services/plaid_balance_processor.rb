class PlaidBalanceProcessor < ApplicationService
  def initialize(access_token)
    @client = PlaidClientCreator.call
    @access_token = access_token
  end

  def call
    begin
      response = @client.accounts.balance.get(@access_token)
      accounts_json = response[:accounts]
      Balance.create_balances_from_accounts_json(accounts_json)
    rescue => e
      Rails.logger.error("Unable to retrieve balance for login item.")
      Rails.logger.error(e)
    end
  end
end