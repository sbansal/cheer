class CreateChats < ActiveRecord::Migration[7.0]
  def change
    create_table :chats do |t|
      t.text :message
      t.integer :user_id

      t.timestamps
    end
  end
end
