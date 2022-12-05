class AddPlaidCursorToLoginItems < ActiveRecord::Migration[7.0]
  def change
    add_column :login_items, :plaid_cursor, :text
  end
end
