class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.string :plaid_transaction_id
      t.float :amount
      t.string :currency_code
      t.jsonb :category_json
      t.string :plaid_category_id
      t.date :occured_at
      t.date :authorized_at
      t.jsonb :location_json
      t.text :description
      t.string :transaction_type
      t.jsonb :payment_meta_json
      t.string :payment_channel
      t.boolean :pending
      t.string :plaid_pending_transaction_id
      t.string :transaction_code
      t.integer :user_id
      t.integer :account_id

      t.timestamps
    end
  end
end
