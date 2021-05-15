class SavingsCalculator < StatCalculator
  def initialize(account)
    super(account)
    @income = IncomeCalculator.call(account)
    @expenses = ExpensesCalculator.call(account)
  end

  def calculate_current_value
    @income[:current_value] - @expenses[:current_value]
  end

  def generate_historical_trend_data
    @income[:historical_trend_data].merge(@expenses[:historical_trend_data]) do |key, income, expense|
      income.abs - expense.abs
    end
  end

  def generate_value_over_time_data
    @income[:value_over_time_data].merge(@expenses[:value_over_time_data]) do |key, income, expense|
      income.abs - expense.abs
    end
  end

  def generate_last_change_data
    {}
  end

end