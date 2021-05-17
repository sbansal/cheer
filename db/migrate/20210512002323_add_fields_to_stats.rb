class AddFieldsToStats < ActiveRecord::Migration[6.1]
  def change
    add_column :stats, :value_over_time_data, :jsonb, default: {}
  end
end
