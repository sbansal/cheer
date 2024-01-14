class Transaction::CategorizedTransaction < Transaction::AggregatedTransactions
  attr_reader :category, :monthly_spend_trend

  delegate :name, to: :category, prefix: true

  def initialize(category, transactions)
    super(category.descriptive_name, transactions)
    @category = category
    @monthly_spend_trend = monthly_spend_trend
  end

  def monthly_spend_trend
    transactions.group_by { |transaction| transaction.occured_at.beginning_of_month }.transform_values do |monthly_transactions|
      monthly_transactions.sum(&:amount)
    end
  end
end