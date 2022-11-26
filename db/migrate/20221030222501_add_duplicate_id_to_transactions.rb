class AddDuplicateIdToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :duplicate_transaction_id, :integer
    add_column :transactions, :duplicate, :boolean, default: false
  end
end
