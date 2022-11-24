class NotificationSubscriptionsController < ApplicationController
  def create
    notification_subscription = NotificationSubscription.find_or_create_by(user: current_user, notification_template_id: params[:notification_template])
    notification_subscription.toggle!(:notify_via_email)
    redirect_to settings_path
  end
end
