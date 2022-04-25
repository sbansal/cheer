class RenameAccountsToCompanies < ActiveRecord::Migration[7.0]
  def change
    rename_table :accounts, :companies
  end
end
