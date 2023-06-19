class AddQueryTypeToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :query_type, :string, default: 'prompt'
  end
end
