class HistoricalTransactionsCreator < ApplicationService
  def initialize(access_token, user, transaction_count=0)
    @client = PlaidClientCreator.call
    @access_token = access_token
    @user = user
    @transaction_count = transaction_count
  end

  def call
    fetch_historical_transactions
  end

  private

  def fetch_historical_transactions
    transactions_fetched_count = 0
    transactions_json_array = []
    end_date = Date.today
    back_off_date = Date.today - 2.years
    until transactions_fetched_count >= @transaction_count  do
      Rails.logger.tagged("TransactionPull") {
        Rails.logger.info { "Total #{transactions_fetched_count}/#{@transaction_count} transactions pulled from Plaid."}
      }
      transactions_json_array += fetch_transactions(end_date)
      transactions_fetched_count = transactions_json_array.length
      if end_date.before?(back_off_date)
        break
      else
        end_date = end_date - 3.month
      end
    end
    Rails.logger.tagged("TransactionPull") {
      Rails.logger.info { "Saving #{transactions_fetched_count} transactions from Plaid into the DB."}
    }
    Transaction.create_transactions_from_json(transactions_json_array.flatten, @user.id)
  end

  def fetch_transactions(end_date)
    start_date = (end_date - 2.month).iso8601
    Rails.logger.tagged("TransactionPull") {
      Rails.logger.info("Fetching transactions for start_date: #{start_date}, end_date: #{end_date}")
    }
    transactions_response = @client.transactions.get(@access_token, start_date, end_date, count: 250, offset: 0)
    transactions_json_array = transactions_response[:transactions]
    total_tx_count = transactions_response[:total_transactions]
    Rails.logger.tagged("TransactionPull") {
      Rails.logger.info "Total transactions that need to be fetched - #{total_tx_count}"
    }
    while transactions_json_array.length < total_tx_count
      transactions_response = @client.transactions.get(
        @access_token,
        start_date,
        end_date,
        count: 250,
        offset: transactions_json_array.length,
      )
      transactions_json_array += transactions_response[:transactions]
    end
    Rails.logger.tagged("TransactionPull") {
      Rails.logger.info "#{transactions_json_array.count}/#{total_tx_count} transactions fetched from Plaid."
    }
    transactions_json_array
  end
end