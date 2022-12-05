class CreateTransactionErrors < ActiveRecord::Migration[7.0]
  def change
    create_table :transaction_errors do |t|
      t.jsonb :transaction_json, nullable: false
      t.integer :user_id, nullable: false
      t.text :error_message, nullable: false
      t.string :error_type

      t.timestamps
    end
  end
end
