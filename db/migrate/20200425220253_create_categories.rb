class CreateCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :categories do |t|
      t.string :group
      t.jsonb :hierarchy
      t.string :plaid_category_id
      t.integer :rank

      t.timestamps
    end
  end
end
