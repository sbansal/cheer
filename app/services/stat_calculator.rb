class StatCalculator < ApplicationService
  def initialize(company)
    @company = company
  end

  def call
    {
      current_value: calculate_current_value,
      last_change_data: generate_last_change_data,
      historical_trend_data: generate_historical_trend_data,
      value_over_time_data: generate_value_over_time_data,
    }
  end

  def generate_value_over_time_data
    {
      Stat::THIS_MONTH => calculate_value_in_range(Date.today.beginning_of_month, Date.today),
      Stat::LAST_MONTH => calculate_value_in_range((Date.today - 1.month).beginning_of_month, (Date.today - 1.month).end_of_month),
      Stat::QUARTERLY => calculate_value_in_range((Date.today - 3.month), Date.today),
      Stat::YEARLY => calculate_value_in_range(Date.today - 1.year, Date.today),
      Stat::ALL => calculate_value_in_range(@company.first_transaction_occured_at, Date.today),
    }
  end

  def generate_historical_trend_data
    {}
  end

  def generate_last_change_data
    {
      Stat::WEEKLY => calculate_change_as_of(Date.today - 1.week),
      Stat::MONTHLY => calculate_change_as_of(Date.today - 1.month),
      Stat::QUARTERLY => calculate_change_as_of(Date.today - 3.months),
      Stat::YEARLY => calculate_change_as_of(Date.today - 1.year),
      Stat::ALL => calculate_change_as_of(@company.first_transaction_occured_at),
    }
  end

  def calculate_change_as_of(date)
    current_value = calculate_current_value
    delta = current_value - value_as_of_date(date)
    delta_percentage = (delta/current_value)*100
    { last_change: delta, last_change_percentage: delta_percentage.round(2) }
  end

  def value_as_of_date(date)
    Rails.logger.warn("Unsupported operation to calculate value on a specific date on the base calculator")
    0
  end

  def calculate_current_value
    Rails.logger.warn("Unsupported operation to calculate current value on the base calculator")
    0
  end

  def calculate_value_in_range(start_date, end_date)
    Rails.logger.warn("Unsupported operation to calculate value for start=#{start_date}, end=#{end_date} on the base calculator")
    0
  end

  def generate_daily_aggregated_transactions_trend(transactions)
    transactions_by_day = transactions.group_by { |tx| tx.occured_at }
    start_day = @company.first_transaction_occured_at
    trend_data = {}
    while(start_day <= Date.today)
      total_income_for_day = transactions_by_day[start_day]&.inject(0) { |sum, tx| sum + tx.amount } || 0
      trend_data[start_day] = total_income_for_day.abs
      start_day = start_day + 1.day
    end
    trend_data
  end

end