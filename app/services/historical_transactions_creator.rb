class HistoricalTransactionsCreator < ApplicationService
  def initialize(access_token, user, transaction_count)
    @client = PlaidClientCreator.call
    @access_token = access_token
    @user = user
    @transaction_count = transaction_count
    @transactions_json_array = []
    @accounts_json_array = []
  end

  def call
    fetch_historical_transactions
  end

  private

  def fetch_historical_transactions
    transactions_fetched_count = 0
    end_date = Date.today
    back_off_date = Date.today - 3.years
    until transactions_fetched_count >= @transaction_count  do
      Rails.logger.tagged("TransactionPull") {
        Rails.logger.info { "Total #{transactions_fetched_count}/#{@transaction_count} transactions pulled from Plaid."}
      }
      fetch_transactions_and_accounts_data(end_date)
      transactions_fetched_count = @transactions_json_array.length
      if end_date.before?(back_off_date)
        break
      else
        end_date = end_date - 3.month
      end
    end
    Rails.logger.tagged("TransactionPull") {
      Rails.logger.info { "Saving #{transactions_fetched_count} transactions from Plaid into the DB."}
    }
    # create the transactions
    Transaction.create_transactions_from_json(@transactions_json_array.flatten, @user.id)
    # update the balances for unique accounts as we want to prevent duplicate updates and balance creation
    BankAccount.update_balances(@accounts_json_array.uniq { |item| item[:account_id] })
  end

  def fetch_transactions_and_accounts_data(end_date)
    start_date = (end_date - 2.month).iso8601
    Rails.logger.tagged("TransactionPull") {
      Rails.logger.info("Fetching transactions for start_date: #{start_date}, end_date: #{end_date}")
    }
    transactions_response = @client.transactions_get(create_transaction_request(start_date, end_date, 0))
    transactions_json = transactions_response.transactions
    total_tx_count = transactions_response.total_transactions
    accounts_json = transactions_response.accounts
    Rails.logger.tagged("TransactionPull") {
      Rails.logger.info "Total transactions that need to be fetched - #{total_tx_count}"
    }
    while transactions_json.length < total_tx_count
      transactions_response = @client.transactions_get(
        create_transaction_request(
          start_date,
          end_date,
          transactions_json.length,
        )
      )
      transactions_json += transactions_response.transactions
      accounts_json += transactions_response.accounts
    end
    Rails.logger.tagged("TransactionPull") {
      Rails.logger.info "#{transactions_json.count}/#{total_tx_count} transactions fetched from Plaid."
    }
    @transactions_json_array += transactions_json
    @accounts_json_array += accounts_json
  end

  def create_transaction_request(start_date, end_date, offset=0)
    Plaid::TransactionsGetRequest.new(
      access_token: @access_token,
      start_date: start_date,
      end_date: end_date,
      options: {
        count: 250,
        offset: offset,
      }
    )
  end
end