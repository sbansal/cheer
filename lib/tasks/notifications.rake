namespace :notifications do
  desc "Send an email containing a weekly summary of finances for each user"
  task send_weekly_summary: :environment do
    User.all.each do |user|
      WeeklyNotificationSenderJob.perform_later(user.id) if user.weekly_summary?
    end
  end

  desc "backfill notifications"
  task backfill_notifications: :environment do |task, args|
    created_at = args[:created_at]
    if created_at
      tx_ids = Transaction.where('created_at > ?', created_at).pluck(:id)
    else
      tx_ids = Transaction.all.pluck(:id)
    end
    NotificationsCreatorJob.perform_later(tx_ids)
  end
end
