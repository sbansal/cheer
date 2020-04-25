class AddIndexToCategories < ActiveRecord::Migration[6.0]
  def change
    add_index :categories, :plaid_category_id, unique: true
  end
end
