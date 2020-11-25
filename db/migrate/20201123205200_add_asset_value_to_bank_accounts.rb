class AddAssetValueToBankAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :bank_accounts, :asset_value, :float
  end
end
