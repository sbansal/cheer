class AddFieldsToSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriptions, :bank_account_id, :integer
    add_column :subscriptions, :description, :string
  end
end
