class EssentialExpensesCalculator < ExpensesCalculator
  def initialize(company)
    super(company)
    @transactions = @company.transactions.where(essential: true).debits
  end
end