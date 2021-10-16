# Preview all emails at http://localhost:3000/rails/mailers/notification
class NotificationPreview < ActionMailer::Preview
  def send_weekly_summary
    NotificationMailer.send_weekly_summary(User.last.id)
  end
end
