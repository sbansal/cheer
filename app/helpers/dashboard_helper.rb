module DashboardHelper
  def format_historical_data(historical_data={})
    value = historical_data[:value]
    if value >= 0
      "+#{number_to_currency(value)} (#{number_to_percentage(historical_data[:percentage], precision: 2)})"
    else
      "#{number_to_currency(value)} (#{number_to_percentage(historical_data[:percentage], precision: 2)})"
    end
  end
  
  def formatted_time_period(start_date, end_date)
    if (start_date.year == end_date.year) && (start_date.year == Date.today.year)
      "#{start_date.strftime('%b %-d')} - #{end_date.strftime('%b %-d')}"
    else
      "#{start_date.strftime('%b %-d, %Y')} - #{end_date.strftime('%b %-d, %Y')}"
    end
  end

  def transaction_to_currency(amount, currency)
    if currency == 'USD'
      number_to_currency(amount)
    else
      number_to_currency(amount, unit: currency)
    end
  end
end
