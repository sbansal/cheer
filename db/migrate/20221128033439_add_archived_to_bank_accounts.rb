class AddArchivedToBankAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :bank_accounts, :archived, :boolean, default: false
  end
end
