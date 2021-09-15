namespace :notifications do
  desc "Send an email containing a weekly summary of finances for each user"
  task send_weekly_summary: :environment do
    User.all.each do |user|
      WeeklyNotificationSenderJob.perform_later(user.id) if user.weekly_summary?
    end
  end

end
