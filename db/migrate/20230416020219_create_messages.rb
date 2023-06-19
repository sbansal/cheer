class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.text :prompt
      t.integer :user_id
      t.integer :chat_id

      t.timestamps
    end
  end
end
