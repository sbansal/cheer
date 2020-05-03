class AddIndexToTransactions < ActiveRecord::Migration[6.0]
  def change
    add_index :transactions, :plaid_transaction_id, unique: true
  end
end
