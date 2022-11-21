class AddTemplateTypeToNotificationTemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :notification_templates, :template_type, :string
    NotificationTemplate.find_by(
      title: NotificationTemplate::DUPLICATE_TEMPLATE_TITLE
    ).update(template_type: NotificationTemplate::DUPLICATE_TEMPLATE_TYPE)
    NotificationTemplate.find_by(
      title: NotificationTemplate::REFUNDS_TEMPLATE_TITLE
    ).update(template_type: NotificationTemplate::REFUNDS_TEMPLATE_TYPE)
    NotificationTemplate.find_by(
      title: NotificationTemplate::FEE_CHARGED_TEMPLATE_TITLE
    ).update(template_type: NotificationTemplate::FEE_CHARGED_TEMPLATE_TYPE)
    NotificationTemplate.find_by(
      title: NotificationTemplate::SALARY_POSTED_TEMPLATE_TITLE
    ).update(template_type: NotificationTemplate::SALARY_POSTED_TEMPLATE_TYPE)
    NotificationTemplate.find_by(
      title: NotificationTemplate::EMAIL_SUMMARY_TEMPLATE_TITLE
    ).update(template_type: NotificationTemplate::EMAIL_SUMMARY_TEMPLATE_TYPE)
  end
end
