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
    Rails.logger.tagged("TransactionsEvent") do
      case event_code
      when INITIAL_UPDATE_CODE
        Rails.logger.info("Intial pull complete. Total new transactions=#{metadata['new_transactions']}")
        # TODO: schedule data pull
      when HISTORICAL_UPDATE_CODE
        Rails.logger.info("Historical pull complete. Total new transactions=#{metadata['new_transactions']}")
        # TODO: schedule data pull
      when DEFAULT_UPDATE_CODE
        Rails.logger.info("New transaction data available. Total new transactions=#{metadata['new_transactions']}")
        # TODO: schedule data pull
      when TRANSACTIONS_REMOVED_CODE
        removed_transactions = metadata['removed_transactions']
        Rails.logger.info("#{removed_transactions.count} transactions removed. Deleting from the database.")
        remove_transactions(remove_transactions)
      else
        Rails.logger.error("Unable to process transactions event code = #{event_code}")
      end
    end
  end
  
  def remove_transactions(removed_transactions)
    Transaction.destroy_by(plaid_transaction_id: removed_transactions)
  end
end