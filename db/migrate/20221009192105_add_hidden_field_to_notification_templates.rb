class AddHiddenFieldToNotificationTemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :notification_templates, :hidden, :boolean, default: false
  end
end
