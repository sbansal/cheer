class CategorizedTransaction
  attr_reader :root_category, :transactions, :total_spend, :categories
  def initialize(root_category, transactions)
    @root_category = root_category
    @transactions = transactions.filter(&:charge?)
    @total_spend = calculate_total_spend
    @categories = process_categories
  end
  
  private
  
  def process_categories
    @transactions.map { |tx| tx.category.secondary_names }&.flatten.uniq.join('/')
  end
  
  def calculate_total_spend
    @transactions.inject(0) { |sum, tx| sum + (tx.amount || 0) }
  end
end