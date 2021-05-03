class CreateStats < ActiveRecord::Migration[6.1]
  def change
    create_table :stats do |t|
      t.string :name
      t.string :description
      t.integer :account_id
      t.float :current_value
      t.jsonb :last_change_data
      t.jsonb :historical_trend_data

      t.timestamps
    end

    add_index :stats, [:account_id, :name], unique: true
  end
end
