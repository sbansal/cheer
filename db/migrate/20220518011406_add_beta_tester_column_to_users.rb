class AddBetaTesterColumnToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :beta_tester, :boolean
    User.update_all(beta_tester: true)
  end
end
