class LiabilitiesCalculator < StatCalculator
  def initialize(account)
    super(account)
  end

  def value_as_of_date(date)
    @account.bank_accounts.liabilities.map { |liability| liability.last_balance_value_on(date) }.sum
  end

  def calculate_current_value
    @account.total_liabilities
  end

  def generate_historical_trend_data
    @account.liabilities_trend
  end

end