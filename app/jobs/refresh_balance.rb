class RefreshBalance
  @queue = :balance

  def self.perform(access_token)
    Rails.logger.info("[ResqueJob][RefreshBalances] Fetching balances")
    PlaidBalanceProcessor.call(access_token)
  end
end