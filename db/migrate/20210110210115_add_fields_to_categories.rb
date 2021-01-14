class AddFieldsToCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :categories, :name, :string
    add_column :categories, :sub_categories, :jsonb

    Category.all.each do |category|
      name = category.primary_name
      children = Category.where("hierarchy @> ? and rank = ?", category.hierarchy.to_s, category.rank + 1)
      sub_categories = children.map { |child| [child.id, child.primary_name]}.to_h
      category.update(name: name, sub_categories: sub_categories)
    end
  end
end
