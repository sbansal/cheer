class AddOauthFieldsToLoginItems < ActiveRecord::Migration[6.1]
  def change
    add_column :login_items, :oauth_access_token, :string
    add_column :login_items, :oauth_refresh_token, :string
    add_column :login_items, :oauth_provider, :string, default: 'plaid'
  end
end
