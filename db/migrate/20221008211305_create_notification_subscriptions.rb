class CreateNotificationSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :notification_subscriptions do |t|
      t.integer :user_id, nullable: false
      t.integer :notification_template_id, nullable: false
      t.boolean :notify_via_email

      t.timestamps
    end
  end
end
