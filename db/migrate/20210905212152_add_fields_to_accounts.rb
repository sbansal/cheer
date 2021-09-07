class AddFieldsToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :bank_accounts, :address_line_1, :text
    add_column :bank_accounts, :address_line_2, :text
  end
end
