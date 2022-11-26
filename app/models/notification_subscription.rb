class NotificationSubscription < ApplicationRecord
  belongs_to :user
  belongs_to :notification_template

  def self.active?(user, notification_template)
    subscription = find_by(user: user, notification_template: notification_template)
    subscription.present? && subscription.notify_via_email
  end
end
