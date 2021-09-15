class NotificationMailer < ApplicationMailer
  def send_weekly_summary(user_id)
    @user = User.find(user_id)
    Rails.logger.info("Sending weekly summary notification to #{@user.email}")
    @account = @user.account
    @period = Stat::WEEKLY

    @net_worth_stat = @account.stats.find_by(name: Stat::NET_WORTH_STAT)
    @net_worth_change = @net_worth_stat.last_change_data[@period]
    @assets_stat = @account.stats.find_by(name: Stat::ASSETS_STAT)
    @assets_change = @assets_stat.last_change_data[@period]
    @liabilities_stat = @account.stats.find_by(name: Stat::LIABILITIES_STAT)
    @liabilities_change = @liabilities_stat.last_change_data[@period]
    @cash_stat = @account.stats.find_by(name: Stat::CASH_STAT)
    @cash_change = @cash_stat.last_change_data[@period]
    @investments_stat = @account.stats.find_by(name: Stat::INVESTMENTS_STAT)
    @investments_change = @investments_stat.last_change_data[@period]
    @cashflow = @account.cashflow(7.days.ago, Time.zone.now)
    mail(:to =>  @user.email, :subject => "Your weekly Net Worth summary from Cheer")
  end
end
