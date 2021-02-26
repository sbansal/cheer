class CategorizedTransaction < AggregatedTransactions
  attr_reader :category_name
  def initialize(category_name, transactions)
    super(transactions)
    @category_name = category_name
  end
end