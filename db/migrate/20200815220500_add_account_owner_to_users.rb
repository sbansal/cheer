class AddAccountOwnerToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :account_owner, :boolean
  end
end
