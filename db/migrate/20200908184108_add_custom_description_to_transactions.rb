class AddCustomDescriptionToTransactions < ActiveRecord::Migration[6.0]
  def up
    add_column :transactions, :custom_description, :text
    Transaction.update_all('custom_description=description')
  end

  def down
    remove_column :transactions, :custom_description
  end
end
