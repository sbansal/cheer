class AssetsCalculator < StatCalculator
  def initialize(company)
    super(company)
  end

  def value_as_of_date(date)
    @company.bank_accounts.assets.map { |asset| asset.last_balance_value_on(date) }.sum
  end

  def calculate_current_value
    @company.total_assets
  end
  
  def generate_historical_trend_data
    @company.assets_trend
  end

end