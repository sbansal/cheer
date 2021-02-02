class AddDescriptionIndexToTransactions < ActiveRecord::Migration[6.1]
  def change
    add_index :transactions, :custom_description
  end
end
