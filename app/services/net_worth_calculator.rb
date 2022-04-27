class NetWorthCalculator < StatCalculator
  def initialize(company)
    super(company)
  end

  def value_as_of_date(date)
    total_assets_balance = @company.bank_accounts.assets.map { |asset| asset.last_balance_value_on(date) }.sum
    total_liability_balance = @company.bank_accounts.liabilities.map { |liability| liability.last_balance_value_on(date) }.sum
    net_worth_on_date = total_assets_balance - total_liability_balance
  end

  def calculate_current_value
    @company.net_worth
  end

  def generate_historical_trend_data
    assets_trend = @company.assets_trend
    liabilities_trend = @company.liabilities_trend
    net_worth_trend = assets_trend.merge(liabilities_trend) do |key, assets_balance, liabilities_balanace|
      assets_balance - liabilities_balanace
    end
  end

end