class RenameColumnsForBankAccounts < ActiveRecord::Migration[6.0]
  def change
    rename_column :bank_accounts, :type, :account_type
    rename_column :bank_accounts, :subtype, :account_subtype
  end
end
