class CategorizedTransaction
  attr_reader :category_name, :transactions, :total_spend, :categories
  def initialize(category_name, transactions)
    @category_name = category_name
    @transactions = transactions.filter(&:charge?)
    @total_spend = calculate_total_spend
    # @categories = process_categories
  end
  
  private
  
  # def process_categories
  #   @transactions.map { |tx| tx.category.secondary_names }&.flatten.uniq.join('/')
  # end
  
  def calculate_total_spend
    @transactions.inject(0) { |sum, tx| sum + (tx.amount || 0) }
  end
end