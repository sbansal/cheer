class RenamePublicTokenFields < ActiveRecord::Migration[6.0]
  def up
    rename_column :login_items, :public_token, :link_token
    rename_column :login_items, :public_token_expired_at, :link_token_expires_at
  end

  def down
    rename_column :login_items, :link_token, :public_token
    rename_column :login_items, :link_token_expires_at, :public_token_expired_at
  end
end
