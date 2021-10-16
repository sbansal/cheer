# Preview all emails at http://localhost:3000/rails/mailers/generic_mailer
class GenericMailerPreview < ActionMailer::Preview
  def login_item_expired_notification
    user = User.last
    GenericMailer.login_item_expired_notification(user.id, user.login_items.last.id)
  end

  def login_item_activated_notification
    user = User.last
    GenericMailer.login_item_activated_notification(user.id, user.login_items.last.id)
  end
end
