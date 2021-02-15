class CategorizedTransaction
  attr_reader :category_name, :transactions, :total_spend, :categories, :count
  def initialize(category_name, transactions)
    @category_name = category_name
    @transactions = transactions
    @total_spend = calculate_total_spend
    @count = @transactions.size
  end

  private

  def calculate_total_spend
    @transactions.inject(0) { |sum, tx| sum + (tx.amount || 0) }
  end
end