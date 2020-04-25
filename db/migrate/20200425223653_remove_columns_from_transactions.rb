class RemoveColumnsFromTransactions < ActiveRecord::Migration[6.0]
  def change
    remove_column :transactions, :plaid_category_id
    remove_column :transactions, :category_json
  end
end
