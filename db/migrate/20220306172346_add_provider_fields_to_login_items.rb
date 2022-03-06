class AddProviderFieldsToLoginItems < ActiveRecord::Migration[7.0]
  def change
    add_column :login_items, :provider_access_token, :string
    add_column :login_items, :provider_refresh_token, :string
  end
end
