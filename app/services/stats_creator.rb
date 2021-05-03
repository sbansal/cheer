class StatsCreator < ApplicationService
  attr_reader :account_id, :stat_name
  def initialize(account_id, stat_name)
    @stat_name = stat_name
    @account_id = account_id
  end

  def call
    stat_description = Stat::SUPPORTED_STATS[stat_name]
    if stat_description
      stat = Stat.find_or_create_by(
        account_id: account_id,
        name: stat_name,
        description: stat_description,
      )
      calculations = build_calculations(@stat_name)
      stat.update(calculations)
      stat
    else
      Rails.logger.error("Cannot create a stat for the stat name=#{stat_name}")
      nil
    end
  end

  private

  def build_calculations(stat_name)
    account = Account.find(@account_id)
    if stat_name.equal?(Stat::NET_WORTH_STAT)
      NetWorthCalculator.call(account)
    elsif stat_name.equal?(Stat::ASSETS_STAT)
      AssetsCalculator.call(account)
    elsif stat_name.equal?(Stat::LIABILITIES_STAT)
      LiabilitiesCalculator.call(account)
    elsif stat_name.equal?(Stat::CASH_STAT)
      CashCalculator.call(account)
    elsif stat_name.equal?(Stat::INVESTMENTS_STAT)
      InvestmentsCalculator.call(account)
    end
  end

end