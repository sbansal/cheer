class AddExpirationInformationToLoginItems < ActiveRecord::Migration[6.0]
  def change
    add_column :login_items, :expired, :boolean, default: false
    add_column :login_items, :expired_at, :datetime
  end
end
