class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.text :description, nullable: false
      t.integer :notification_template_id, nullable: false
      t.text :reference_entity_gid
      t.integer :user_id, nullable: false

      t.timestamps
    end
  end
end
