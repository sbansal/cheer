class UpdatesToLoginItems < ActiveRecord::Migration[6.0]
  def change
    change_column_null :login_items, :plaid_item_id, true
    change_column_null :login_items, :plaid_access_token, true
    remove_index :login_items, :plaid_item_id
  end
end
