class StatsCreator < ApplicationService
  attr_reader :account_id, :stat_name
  def initialize(account_id, stat_name)
    @stat_name = stat_name
    @account_id = account_id
  end

  def call
    if stat_description = Stat::SUPPORTED_STATS[@stat_name]
      create_stat(@stat_name, stat_description)
    else
      create_all_stats
    end
  end

  private

  def create_all_stats
    Stat::SUPPORTED_STATS.each do |name, description|
      create_stat(name, description)
    end
  end

  def create_stat(name, description)
    Rails.logger.info("Updating stat: #{name} for account_id:#{account_id}")
    stat = Stat.find_or_create_by(
      account_id: @account_id,
      name: name,
      description: description,
    )
    calculations = build_calculations(name)
    stat.update(calculations)
    Rails.logger.info("Stat calculations updated, #{stat.inspect}")
    stat
  end

  def build_calculations(name)
    account = Account.find(@account_id)
    if name.eql?(Stat::NET_WORTH_STAT)
      NetWorthCalculator.call(account)
    elsif name.eql?(Stat::ASSETS_STAT)
      AssetsCalculator.call(account)
    elsif name.eql?(Stat::LIABILITIES_STAT)
      LiabilitiesCalculator.call(account)
    elsif name.eql?(Stat::CASH_STAT)
      CashCalculator.call(account)
    elsif name.eql?(Stat::INVESTMENTS_STAT)
      InvestmentsCalculator.call(account)
    elsif name.eql?(Stat::INCOME_STAT)
      IncomeCalculator.call(account)
    elsif name.eql?(Stat::EXPENSES_STAT)
      ExpensesCalculator.call(account)
    elsif name.eql?(Stat::SAVINGS_STAT)
      SavingsCalculator.call(account)
    elsif name.eql?(Stat::ESSENTIAL_EXPENSES_STAT)
      EssentialExpensesCalculator.call(account)
    elsif name.eql?(Stat::NON_ESSENTIAL_EXPENSES_STAT)
      NonEssentialExpensesCalculator.call(account)
    end
  end

end