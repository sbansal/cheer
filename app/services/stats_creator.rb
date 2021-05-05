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
    if name.equal?(Stat::NET_WORTH_STAT)
      NetWorthCalculator.call(account)
    elsif name.equal?(Stat::ASSETS_STAT)
      AssetsCalculator.call(account)
    elsif name.equal?(Stat::LIABILITIES_STAT)
      LiabilitiesCalculator.call(account)
    elsif name.equal?(Stat::CASH_STAT)
      CashCalculator.call(account)
    elsif name.equal?(Stat::INVESTMENTS_STAT)
      InvestmentsCalculator.call(account)
    end
  end

end