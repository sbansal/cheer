class RelatedTransactionsCreatorJob < ApplicationJob
  queue_as :transactions

  def perform(transaction_gid, transaction_params, related_transaction_ids)
    Rails.logger.info("[ResqueJob][RelatedTransactionsCreatorJob] Creating related jobs for #{transaction_gid}")
    transaction = GlobalID::Locator.locate(transaction_gid)
    transaction.update_related(transaction_params, related_transaction_ids)
  end
end
