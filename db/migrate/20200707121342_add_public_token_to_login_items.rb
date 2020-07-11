class AddPublicTokenToLoginItems < ActiveRecord::Migration[6.0]
  def change
    add_column :login_items, :public_token, :string
    add_column :login_items, :public_token_expired_at, :datetime
  end
end
