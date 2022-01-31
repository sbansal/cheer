class PlaidBalanceProcessor < ApplicationService
  def initialize(access_token)
    @client = PlaidClientCreator.call
    @access_token = access_token
    @login_item = LoginItem.find_by(plaid_access_token: @access_token)
  end

  def call
    begin
      if @login_item.expired?
        Rails.logger.warn("[PlaidBalanceProcessor] LoginItem with ID=#{@login_item.item} is expired hence not refreshing the balance.")
      else
        request = Plaid::AccountsBalanceGetRequest.new({ access_token: @access_token })
        response = @client.accounts_balance_get(request)
        accounts_json = response.accounts
        BankAccount.update_balances(accounts_json)
      end
    rescue => e
      Rails.logger.error("[PlaidBalanceProcessor] Unable to retrieve balance for login item with ID=#{@login_item.id}")
      Rails.logger.error(e)
    end
  end
end
