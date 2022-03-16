class Transaction::AggregatedTransactions
  attr_reader :transactions, :total_spend, :count, :aggregation

  def initialize(aggregation, transactions)
    @aggregation = aggregation
    @transactions = transactions
  end

  def total_spend
    @total_spend ||= @transactions.inject(0) { |sum, tx| sum + (tx.amount || 0) }
  end

  def count
    @count ||= @transactions.size
  end
end