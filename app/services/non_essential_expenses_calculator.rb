class NonEssentialExpensesCalculator < ExpensesCalculator
  def initialize(company)
    super(company)
    @transactions = @company.transactions.where(essential: false).debits
  end
end
