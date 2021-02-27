namespace :scheduler do
  desc "This task refreshes the balances for all the accounts based on a schedule"
  task refresh_balances: :environment do
    Rails.logger.info("[Scheduler][RefreshBalances] Scheduling the balance refresh at #{Time.zone.now}")
    LoginItem.all.each do |login|
      access_token = login.plaid_access_token
      RefreshBalanceJob.perform_later(access_token)
    end
  end
end
