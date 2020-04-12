class CreateLoginItems < ActiveRecord::Migration[6.0]
  def change
    create_table :login_items do |t|
      t.string :plaid_item_id, null: false
      t.string :plaid_access_token, null: false
      t.integer :institution_id
      t.datetime :consent_expires_at
      t.jsonb :error_json
      t.datetime :last_successful_transaction_update_at
      t.datetime :last_failed_transaction_update_at
      t.datetime :last_webhook_sent_at
      t.string :last_webhook_code_sent
      t.integer :user_id, null: false

      t.timestamps
    end

    add_index :login_items, :plaid_item_id, unique: true
  end
end
