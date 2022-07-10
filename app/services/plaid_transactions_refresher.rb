class PlaidTransactionsRefresher < ApplicationService
  def initialize(access_token)
    @access_token = access_token
  end

  def call
    request = Plaid::TransactionsRefreshRequest.new(
      {
        access_token: @access_token,
      }
    )
    PlaidClientCreator.call.transactions_refresh(request)
  end
end
