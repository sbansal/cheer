class AddFieldsToCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :categories, :name, :string
    add_column :categories, :hierarchy_string, :text

    Category.all.each do |category|
      category.update(name: category.primary_name, hierarchy_string: category.category_list)
    end
  end
end
