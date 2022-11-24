class CreateNotificationTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :notification_templates do |t|
      t.text :title, nullable: false
      t.string :frequency, nullable: false

      t.timestamps
    end
  end
end
