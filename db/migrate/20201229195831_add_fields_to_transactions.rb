class AddFieldsToTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :transactions, :merchant_name, :string
  end
end
