class StatsCreator < ApplicationService
  attr_reader :company_id, :stat_name
  def initialize(company_id, stat_name)
    @stat_name = stat_name
    @company_id = company_id
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
    Rails.logger.info("Updating stat: #{name} for company_id:#{company_id}")
    stat = Stat.find_or_create_by(
      company_id: @company_id,
      name: name,
      description: description,
    )
    calculations = build_calculations(name)
    stat.update(calculations)
    Rails.logger.info("Stat calculations updated, #{name}")
    stat
  end

  def build_calculations(name)
    company = Company.find(@company_id)
    if name.eql?(Stat::NET_WORTH_STAT)
      NetWorthCalculator.call(company)
    elsif name.eql?(Stat::ASSETS_STAT)
      AssetsCalculator.call(company)
    elsif name.eql?(Stat::LIABILITIES_STAT)
      LiabilitiesCalculator.call(company)
    elsif name.eql?(Stat::CASH_STAT)
      CashCalculator.call(company)
    elsif name.eql?(Stat::INVESTMENTS_STAT)
      InvestmentsCalculator.call(company)
    elsif name.eql?(Stat::INCOME_STAT)
      IncomeCalculator.call(company)
    elsif name.eql?(Stat::EXPENSES_STAT)
      ExpensesCalculator.call(company)
    elsif name.eql?(Stat::SAVINGS_STAT)
      SavingsCalculator.call(company)
    elsif name.eql?(Stat::ESSENTIAL_EXPENSES_STAT)
      EssentialExpensesCalculator.call(company)
    elsif name.eql?(Stat::NON_ESSENTIAL_EXPENSES_STAT)
      NonEssentialExpensesCalculator.call(company)
    end
  end

end