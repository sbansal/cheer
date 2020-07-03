class HistoricalTransactionsCreator < ApplicationService
  def initialize(access_token, user, transaction_count)
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
    until @transaction_count > transactions_fetched_count do
      transactions_json_array << fetch_transactions(end_date)
      transactions_fetched_count = transactions_json_array.length
      if end_date < (Date.today - 2.years)
        break
      else
        end_date = end_date - 2.month
      end
    end
    Transaction.create_transactions_from_json(transactions_json_array.flatten, @user.id)
  end

  def fetch_transactions(end_date)
    start_date = (end_date - 2.month).iso8601
    Rails.logger.tagged("TransactionPull") { 
      Rails.logger.info("Fetching transactions for start_date: #{start_date}, end_date: #{end_date}")
    }
    transactions_response = @client.transactions.get(
      @access_token,
      start_date,
      end_date
    )
    transactions_json_array = transactions_response[:transactions]
    Rails.logger.tagged("TransactionPull") { 
      Rails.logger.info "Total transactions that need to be fetched - #{transactions_response[:total_transactions]}"
    }
    while transactions_json_array.length < transactions_response[:total_transactions]
      transactions_response = @client.transactions.get(
        @access_token,
        @start_date_iso8601_str,
        @end_date_iso8601_str
      )
      transactions_json_array << transactions_response[:transactions]
    end
    transactions_json_array
  end
end