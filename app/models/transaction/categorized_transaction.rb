class Transaction::CategorizedTransaction < Transaction::AggregatedTransactions
  attr_reader :category

  delegate :name, to: :category, prefix: true

  def initialize(category, transactions)
    super(category.descriptive_name, transactions)
    @category = category
  end

end