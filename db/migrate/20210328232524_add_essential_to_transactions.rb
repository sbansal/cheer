class AddEssentialToTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :transactions, :essential, :boolean
    Transaction.all.each do |tx|
      tx.update(essential: tx.category.essential?)
    end
  end
end
