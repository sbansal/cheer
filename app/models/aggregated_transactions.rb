class AggregatedTransactions
  attr_reader :transactions, :total_spend, :count
  def initialize(transactions)
    @transactions = transactions
    @total_spend = @transactions.inject(0) { |sum, tx| sum + (tx.amount || 0) }
    @count = @transactions.size
  end
end