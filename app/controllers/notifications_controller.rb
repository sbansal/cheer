class NotificationsController < ApplicationController
  include Pagy::Backend

  def index
    @notifications = current_company.notifications.where(read: false)
    @notifications_count = @notifications.count
    @pagy, @notifications = pagy(@notifications, items: 25)
  end

  def update
    notifications = current_company.notifications.where(read: false).update_all(read: true)
    flash[:notice_header] = 'Notifications marked as read.'
    flash[:notice] = "All unread notifications have been marked as read."
    redirect_to notifications_url
  end
end
