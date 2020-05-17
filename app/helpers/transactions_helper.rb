module TransactionsHelper
  def transactions_total(transactions=[])
    total = transactions.map { |tx| tx.amount }.sum
    number_to_currency(total)
  end
end
