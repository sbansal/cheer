class AddFieldsToBankAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :bank_accounts, :provider_item_id, :string
    add_column :bank_accounts, :native_balance, :float
    add_column :bank_accounts, :native_currency, :string
  end
end
