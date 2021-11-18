class StatCalculator < ApplicationService
  def initialize(account)
    @account = account
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
      Stat::THIS_MONTH => calculate_value_in_range(Time.zone.now.beginning_of_month, Time.zone.now),
      Stat::LAST_MONTH => calculate_value_in_range(Time.zone.now.beginning_of_month - 1.month, Time.zone.now.end_of_month - 1.month),
      Stat::QUARTERLY => calculate_value_in_range(3.months.ago, Time.zone.now),
      Stat::YEARLY => calculate_value_in_range(1.year.ago, Time.zone.now),
      Stat::ALL => calculate_value_in_range(30.year.ago, Time.zone.now),
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

  def generate_aggregated_transactions_by_month_trend(transactions)
    transactions_by_month = transactions.group_by { |tx| tx.occured_at.beginning_of_month }
    start_month = transactions_by_month.keys.first
    trend_data = {}
    if start_month
      while(start_month <= Date.today.beginning_of_month)
        total_income_for_month = transactions_by_month[start_month]&.inject(0) { |sum, tx| sum + tx.amount } || 0
        trend_data[start_month] = total_income_for_month.abs
        start_month = start_month + 1.month
      end
    end
    trend_data
  end

end