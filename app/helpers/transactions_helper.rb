module TransactionsHelper
  def transactions_total(transactions=[])
    total = transactions.map { |tx| tx.amount }.sum
    number_to_currency(total)
  end

  def tx_amount_type(amount)
    if amount > 0
      "Debit"
    else
      "Credit"
    end
  end
end
