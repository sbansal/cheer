class RefreshBalanceJob < ApplicationJob
  @queue = :balance

  def perform(access_token)
    Rails.logger.info("[ResqueJob][RefreshBalances] Fetching balances")
    PlaidBalanceProcessor.call(access_token)
  end
end