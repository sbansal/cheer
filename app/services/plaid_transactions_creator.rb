class PlaidTransactionsCreator < ApplicationService
  def initialize(access_token, user, start_date, end_date)
    @client = PlaidClientCreator.call
    @access_token = access_token
    @user = user
    @start_date_iso8601_str = start_date
    @end_date_iso8601_str = end_date
    @transactions_json_array = []
    @account_json_array = []
    @login_item = LoginItem.find_by(plaid_access_token: @access_token)
  end

  def call
    begin
      add_transactions
    rescue Plaid::ApiError => e
      Rails.logger.error("[PlaidTransactionsCreator] Unable to add transactions for login item with ID=#{@login_item&.id}")
      Rails.logger.error(e.response_body)
      if item_expired?(e)
        Rails.logger.info("[PlaidTransactionsCreator] Expiring login item with ID=#{@login_item&.id}.")
        @login_item&.expire
      end
    rescue => e
      Rails.logger.error("[PlaidTransactionsCreator] Unable to add transactions for login item with ID=#{@login_item&.id}")
      Rails.logger.error(e)
    ensure
      upserter_result = Transaction.create_transactions_from_json(@transactions_json_array.flatten, @user.id)
      upserted_transaction_ids = upserter_result.map {|result| result["id"]}
      BankAccount.update_balances(@account_json_array.uniq { |item| item.account_id })
      DuplicateTransactionsProcessor.call(upserted_transaction_ids)
      StatsCreatorJob.perform_later(@user.company_id)
      NotificationsCreatorJob.perform_later(upserted_transaction_ids)
    end
  end

  private

  def add_transactions
    Rails.logger.info("[TransactionPull] Fetching transactions for start_date: #{@start_date_iso8601_str}, end_date: #{@end_date_iso8601_str}")
    transactions_response = @client.transactions_get(create_transaction_request(0))
    @transactions_json_array = transactions_response.transactions
    @account_json_array = transactions_response.accounts
    Rails.logger.info("[TransactionPull] Total transactions that need to be fetched - #{transactions_response.total_transactions}")
    while @transactions_json_array.length < transactions_response.total_transactions
      transactions_response = @client.transactions_get(create_transaction_request(@transactions_json_array.length))
      @transactions_json_array += transactions_response.transactions
      @account_json_array += transactions_response.accounts
    end
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
