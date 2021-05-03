class CashCalculator < StatCalculator
  def initialize(account)
    super(account)
  end

  def value_as_of_date(date)
    @account.bank_accounts.assets.liquid_accounts.map { |asset| asset.last_balance_value_on(date) }.sum
  end

  def calculate_current_value
    @account.total_cash_assets
  end

end