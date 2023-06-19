class AssetAllocationCalculator < ApplicationService
  def initialize(asset_accounts)
    @asset_accounts = asset_accounts
  end

  def call
    generate_asset_allocation_report
  end

  private

  def generate_asset_allocation_report
    total_balance = @asset_accounts.sum { |account| account[:current_balance].to_f }
    report_data = @asset_accounts.map do |account|
      percentage = (account[:current_balance].to_f / total_balance * 100).round(2)
      { account_type: account[:account_type], account_subtype: account[:account_subtype], classification: account[:classification], percentage: percentage }
    end
  
    { total_balance: total_balance, report_data: report_data }
  end
end