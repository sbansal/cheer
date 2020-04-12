class UpdatesToBankAccounts < ActiveRecord::Migration[6.0]
  def change
    change_column_null :bank_accounts, :plaid_account_id, true
    change_column_null :bank_accounts, :login_item_id, true
    remove_index :bank_accounts, :plaid_account_id
  end
end
