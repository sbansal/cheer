class NotificationTemplatesController < ApplicationController
  def index
    @notification_templates = NotificationTemplate.all
    @notification_template = NotificationTemplate.new
  end

  def edit
    @notification_template = NotificationTemplate.find(params[:id])
  end

  def create
    @notification_template = NotificationTemplate.new(template_params)
    if @notification_template.save
      flash[:notice_header] = 'Notification template created.'
      flash[:notice] = "New template - #{@notification_template.title} has been created successfully."
      redirect_to(notification_templates_path)
    else
      flash[:alert_header] = 'Notification template not created.'
      flash[:alert] = "There was an error creating the template. Please check your entries and try again."
      redirect_to(notification_templates_path)
    end
  end

  def update
    @notification_template = NotificationTemplate.find(params[:id])
    if @notification_template.update(template_params)
      flash[:notice_header] = 'Notification template updated.'
      flash[:notice] = "Template with title - #{@notification_template.title} has been updated successfully."
      redirect_to(notification_templates_path)
    else
      flash[:alert_header] = 'Notification template not saved.'
      flash[:alert] = "There was an error updating the template. Please check your entries and try again."
      redirect_to(notification_templates_path)
    end
  end

  private

  def template_params
    params.require(:notification_template).permit(:title, :frequency, :hidden)
  end
end
