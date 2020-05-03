class AddColumnsToCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :essential, :boolean
  end
end
