class DuplicateTransactionsProcessor < ApplicationService
  def initialize(transaction_ids)
    @transaction_ids = transaction_ids
  end
  
  def call
    @transaction_ids.filter_map do |transaction_id|
      tx = Transaction.find(transaction_id)
      tx.tag_duplicates
    end
  end
end