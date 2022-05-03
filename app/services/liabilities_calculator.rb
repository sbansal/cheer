class LiabilitiesCalculator < StatCalculator
  def initialize(company)
    super(company)
  end

  def value_as_of_date(date)
    @company.bank_accounts.liabilities.map { |liability| liability.last_balance_value_on(date) }.sum
  end

  def calculate_current_value
    @company.total_liabilities
  end

  def generate_historical_trend_data
    @company.liabilities_trend
  end

end