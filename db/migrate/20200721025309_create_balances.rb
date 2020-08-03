class CreateBalances < ActiveRecord::Migration[6.0]
  def change
    create_table :balances do |t|
      t.float :available
      t.float :current
      t.float :limit
      t.string :currency_code
      t.integer :bank_account_id
      t.integer :user_id

      t.timestamps
    end
  end
end
