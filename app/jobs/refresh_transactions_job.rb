class RefreshTransactionsJob < ApplicationJob
  queue_as :transactions

  def perform(access_token, user_id, start_date, end_date)
    Rails.logger.info("[ResqueJob][RefreshTransactionsJob] Fetching transactions")
    PlaidTransactionsCreator.call(access_token, User.find(user_id), start_date, end_date)
  end
end
