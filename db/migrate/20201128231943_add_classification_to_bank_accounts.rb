class AddClassificationToBankAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :bank_accounts, :classification, :string
  end
end
