class AddNewAccountsAvailableToLoginItems < ActiveRecord::Migration[7.0]
  def change
    add_column :login_items, :new_accounts_available, :boolean, default: false
  end
end
