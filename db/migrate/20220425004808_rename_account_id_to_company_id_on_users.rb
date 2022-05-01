class RenameAccountIdToCompanyIdOnUsers < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :account_id, :company_id
  end
end
