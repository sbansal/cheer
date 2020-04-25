class AddCategoryIdToTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :transactions, :category_id, :integer
  end
end
