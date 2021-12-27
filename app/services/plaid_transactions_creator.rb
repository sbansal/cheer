class PlaidTransactionsCreator < ApplicationService
  def initialize(access_token, user, start_date, end_date)
    @client = PlaidClientCreator.call
    @access_token = access_token
    @user = user
    @start_date_iso8601_str = start_date
    @end_date_iso8601_str = end_date
  end

  def call
    add_transactions
  end

  private

  def add_transactions
    Rails.logger.tagged("TransactionPull") {
      Rails.logger.info("Fetching transactions for start_date: #{@start_date_iso8601_str}, end_date: #{@end_date_iso8601_str}")
    }
    transactions_response = @client.transactions_get(create_transaction_request(0))
    transactions_json_array = transactions_response.transactions
    account_json_array = transactions_response.accounts
    Rails.logger.tagged("TransactionPull") {
      Rails.logger.info "Total transactions that need to be fetched - #{transactions_response.total_transactions}"
    }
    while transactions_json_array.length < transactions_response.total_transactions
      transactions_response = @client.transactions_get(create_transaction_request(transactions_json_array.length))
      transactions_json_array += transactions_response.transactions
      account_json_array += transactions_response.accounts
    end
    Transaction.create_transactions_from_json(transactions_json_array.flatten, @user.id)
    BankAccount.update_balances(account_json_array.uniq { |item| item.account_id })
    StatsCreatorJob.perform_later(@user.account_id)
  end

  def create_transaction_request(offset=0)
    Plaid::TransactionsGetRequest.new(
      access_token: @access_token,
      start_date: @start_date_iso8601_str,
      end_date: @end_date_iso8601_str,
      options: {
        count: 250,
        offset: offset,
      }
    )
  end
end
