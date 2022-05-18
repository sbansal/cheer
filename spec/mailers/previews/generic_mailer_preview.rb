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

  def customer_subscription_created_notification
    user = User.last
    GenericMailer.customer_subscription_created_notification(user.id)
  end

  def customer_subscription_deleted_notification
    user = User.where('stripe_subscription_id is not null').first
    GenericMailer.customer_subscription_deleted_notification('sub_1KzXUML3IISqheXWnF4eFiPx', user.id)
  end
end
