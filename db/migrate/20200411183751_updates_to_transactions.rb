class UpdatesToTransactions < ActiveRecord::Migration[6.0]
  def change
    change_column_default :transactions, :pending, false
    rename_column :transactions, :account_id, :bank_account_id
  end
end
