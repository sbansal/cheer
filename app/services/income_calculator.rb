class IncomeCalculator < StatCalculator
  def initialize(company)
    super(company)
    @transactions = @company.transactions.credits
  end

  def calculate_current_value
    @transactions.sum(:amount).abs
  end

  def generate_historical_trend_data
    generate_daily_aggregated_transactions_trend(@transactions.reverse)
  end

  def calculate_value_in_range(start_date, end_date)
    @transactions.occured_between(start_date, end_date).sum(:amount).abs
  end

  def generate_last_change_data
    {}
  end

end