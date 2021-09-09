# Preview all emails at http://localhost:3000/rails/mailers/notification
class NotificationPreview < ActionMailer::Preview
  def send_summary
    NotificationMailer.send_summary(User.last.id)
  end
end
