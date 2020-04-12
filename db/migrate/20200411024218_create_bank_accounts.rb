class CreateBankAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :bank_accounts do |t|
      t.string :plaid_account_id, null: false
      t.string :name
      t.string :official_name
      t.string :type
      t.string :subtype
      t.string :mask
      t.float :balance_available
      t.float :balance_limit
      t.string :balance_currency_code
      t.integer :login_item_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end

    add_index :bank_accounts, :plaid_account_id, unique: true
  end
end
