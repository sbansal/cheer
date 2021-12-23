class AddCoinbaseIdToBankAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :bank_accounts, :coinbase_account_id, :string
    add_column :bank_accounts, :native_balance, :float
    add_column :bank_accounts, :native_currency, :string
  end
end
