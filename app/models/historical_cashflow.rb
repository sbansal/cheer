class HistoricalCashflow
  attr_reader :monthly_trends, :weekly_trends, :daily_trends
  
  def initialize(transactions)
    build_monthly_trend(transactions)
    build_weekly_trend(transactions)
    build_daily_trend(transactions)
    update_deltas
  end
  
  def chart_data(period)
    if period == 'monthly'
      trends = @monthly_trends
    elsif period == 'weekly'
      trends = @weekly_trends
    else
      trends = @daily_trends
    end
    money_in_trend = trends.map { |trend| [trend[:date], trend[:cashflow].total_money_in.abs] }.reverse
    money_out_trend = trends.map.map { |trend| [trend[:date], trend[:cashflow].total_money_out.abs] }.reverse
    money_saved_trend = trends.map.map { |trend| [trend[:date], trend[:cashflow].total_money_saved] }.reverse
    { money_in: money_in_trend, money_out: money_out_trend, money_saved: money_saved_trend }
  end
  
  private

  def build_weekly_trend(transactions)
    @weekly_trends = transactions.group_by { |tx| tx.occured_at.beginning_of_week }.map do |week, transactions|
      { date: week, cashflow: Cashflow.new(transactions) }
    end
  end

  def build_monthly_trend(transactions)
    @monthly_trends = transactions.group_by { |tx| tx.occured_at.beginning_of_month }.map do |month, transactions|
      { date: month, cashflow: Cashflow.new(transactions) }
    end
  end
  
  def build_daily_trend(transactions)
    @daily_trends = transactions.group_by { |tx| tx.occured_at.beginning_of_day }.map do |date, transactions|
      { date: date, cashflow: Cashflow.new(transactions) }
    end
  end
  
  def update_deltas
    @monthly_trends.each_with_index do |trend, index|
      trend[:cashflow].update_delta(@monthly_trends[index+1][:cashflow]) if index < @monthly_trends.length - 1
    end
  end
end