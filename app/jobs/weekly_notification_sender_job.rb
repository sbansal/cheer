class WeeklyNotificationSenderJob < ApplicationJob
  queue_as :mailers

  def perform(user_id)
    NotificationMailer.send_weekly_summary(user_id).deliver_later
  end
end
