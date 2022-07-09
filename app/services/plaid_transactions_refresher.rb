class PlaidTransactionsRefresher < ApplicationService
  def initialize(access_token, login_item_gid)
    @access_token = access_token
    @login_item_gid = login_item_gid
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
