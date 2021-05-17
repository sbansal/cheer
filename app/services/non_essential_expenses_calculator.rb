class NonEssentialExpensesCalculator < ExpensesCalculator
  def initialize(account)
    super(account)
    @transactions = @account.transactions.where(essential: false).debits
  end
end
