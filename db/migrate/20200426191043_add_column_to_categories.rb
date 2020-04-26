class AddColumnToCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :descriptive_name, :string
  end
end
