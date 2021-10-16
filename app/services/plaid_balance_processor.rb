class PlaidBalanceProcessor < ApplicationService
  def initialize(access_token)
    @client = PlaidClientCreator.call
    @access_token = access_token
  end

  def call
    begin
      if LoginItem.find_by(plaid_access_token: @access_token).expired?
        Rails.logger.warn("[PlaidBalanceProcessor] LoginItem is expired hence not refreshing the balance.")
      else
        response = @client.accounts.balance.get(@access_token)
        accounts_json = response[:accounts]
        BankAccount.update_balances(accounts_json)
      end
    rescue => e
      Rails.logger.error("[PlaidBalanceProcessor] Unable to retrieve balance for login item.")
      Rails.logger.error(e)
    end
  end
end
