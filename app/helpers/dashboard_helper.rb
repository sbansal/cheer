module DashboardHelper
  def format_historical_data(historical_data={})
    value = historical_data[:value]
    sign = historical_data[:value] >= 0 ? "+" : "-"
    "#{sign}#{number_to_currency(value)} (#{number_to_percentage(historical_data[:percentage], precision: 2)})"
  end
end
