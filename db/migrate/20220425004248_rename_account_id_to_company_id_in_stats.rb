class RenameAccountIdToCompanyIdInStats < ActiveRecord::Migration[7.0]
  def change
    rename_column :stats, :account_id, :company_id
  end
end
