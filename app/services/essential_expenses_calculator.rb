class EssentialExpensesCalculator < ExpensesCalculator
  def initialize(account)
    super(account)
    @transactions = @account.transactions.where(essential: true).debits
  end
end