class TransactionsEventProcessor < EventProcessor

  INITIAL_UPDATE_CODE = 'INITIAL_UPDATE'
  HISTORICAL_UPDATE_CODE = 'HISTORICAL_UPDATE'
  DEFAULT_UPDATE_CODE = 'DEFAULT_UPDATE'
  TRANSACTIONS_REMOVED_CODE = 'TRANSACTIONS_REMOVED'

  def initialize(event_code, item_id, metadata={})
    super(event_code, item_id, metadata)
  end

  private

  def process_event
    case event_code
    when INITIAL_UPDATE_CODE
      Rails.logger.info("[WebhookEvent:TransactionsEvent] Initial pull complete. Total new transactions=#{metadata['new_transactions']}")
      fetch_new_transactions(30)
    when HISTORICAL_UPDATE_CODE
      transactions_count = metadata['new_transactions']
      Rails.logger.info("[WebhookEvent:TransactionsEvent] Historical pull complete. Total new transactions=#{transactions_count}")
      fetch_historical_transactions(transactions_count)
    when DEFAULT_UPDATE_CODE
      Rails.logger.info("[WebhookEvent:TransactionsEvent] New transaction data available. Total new transactions=#{metadata['new_transactions']}")
      fetch_new_transactions
    when TRANSACTIONS_REMOVED_CODE
      removed_transactions = metadata['removed_transactions']
      Rails.logger.info("[WebhookEvent:TransactionsEvent] #{removed_transactions.count} transactions removed. Deleting from the database.")
      remove_transactions(removed_transactions)
    else
      Rails.logger.error("[WebhookEvent:TransactionsEvent] Unable to process transactions event code = #{event_code}")
    end
  end

  def remove_transactions(removed_transactions)
    Transaction.destroy_by(plaid_transaction_id: removed_transactions)
  end

  def fetch_new_transactions(num_days=1)
    user = login_item.user
    PlaidTransactionsCreator.call(
      login_item.plaid_access_token,
      user,
      (user.last_transaction_pulled_at - num_days.day).iso8601,
      Date.today.iso8601,
    )
  end

  def fetch_historical_transactions(transactions_count)
    HistoricalTransactionsCreator.call(
      login_item.plaid_access_token,
      login_item.user,
      transactions_count,
    )
  end
end