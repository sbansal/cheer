class NetWorthCalculator < StatCalculator
  def initialize(account)
    super(account)
  end

  def value_as_of_date(date)
    total_assets_balance = @account.bank_accounts.assets.map { |asset| asset.last_balance_value_on(date) }.sum
    total_liability_balance = @account.bank_accounts.liabilities.map { |liability| liability.last_balance_value_on(date) }.sum
    net_worth_on_date = total_assets_balance - total_liability_balance
  end

  def calculate_current_value
    @account.net_worth
  end

  def generate_historical_trend_data
    assets_trend = @account.assets_trend
    liabilities_trend = @account.liabilities_trend
    net_worth_trend = assets_trend.merge(liabilities_trend) do |key, assets_balance, liabilities_balanace|
      assets_balance - liabilities_balanace
    end
  end

end