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
    Rails.logger.tagged("TransactionPull") do
      Rails.logger.info("Fetching transactions for start_date: #{@start_date_iso8601_str}, end_date: #{@end_date_iso8601_str}")
      transactions_response = @client.transactions.get(
        @access_token,
        @start_date_iso8601_str,
        @end_date_iso8601_str
      )
      transactions_json_array = transactions_response[:transactions]
      Rails.logger.info "Total transactions that need to be fetched - #{transactions_response[:total_transactions]}"
      while transactions_json_array.length < transactions_response[:total_transactions]
        transactions_response = @client.transactions.get(
          @access_token,
          @start_date_iso8601_str,
          @end_date_iso8601_str
        )
        transactions_json_array << transactions_response[:transactions]
      end
      Transaction.create_transactions_from_json(transactions_json_array.flatten, @user.id)
    end
  end
end