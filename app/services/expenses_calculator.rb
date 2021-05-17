class ExpensesCalculator < StatCalculator
  def initialize(account)
    super(account)
    @transactions = @account.transactions.debits
  end

  def calculate_current_value
    @transactions.sum(:amount)
  end

  def generate_historical_trend_data
    generate_aggregated_transactions_by_month_trend(@transactions.reverse)
  end

  def calculate_value_in_range(start_date, end_date)
    @transactions.occured_between(start_date, end_date).sum(:amount)
  end

  def generate_last_change_data
    {}
  end

end