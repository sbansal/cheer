class StatCalculator < ApplicationService
  def initialize(account)
    @account = account
  end

  def call
    {
      current_value: calculate_current_value,
      last_change_data: generate_last_change_data,
      historical_trend_data: generate_historical_trend_data,
    }
  end

  def generate_historical_trend_data
     {}
  end

  def generate_last_change_data
    {
      Stat::WEEKLY => calculate_change_as_of(1.week.ago),
      Stat::MONTHLY => calculate_change_as_of(1.month.ago),
      Stat::QUARTERLY => calculate_change_as_of(3.months.ago),
      Stat::YEARLY => calculate_change_as_of(1.year.ago),
      Stat::ALL => calculate_change_as_of(30.year.ago),
    }
  end

  def calculate_change_as_of(date)
    current_value = calculate_current_value
    delta = current_value - value_as_of_date(date)
    delta_percentage = (delta/current_value)*100
    { last_change: delta, last_change_percentage: delta_percentage.round(2) }
  end

  def value_as_of_date(date)
    Rails.logger.error("Unsupport operation to calculate value on a specific date on the base calculator")
  end

  def calculate_current_value
    Rails.logger.error("Unsupport operation to calculate current value on the base calculator")
  end

end