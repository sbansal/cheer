class AddActiveToSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :active, :boolean, default: false
  end
end
