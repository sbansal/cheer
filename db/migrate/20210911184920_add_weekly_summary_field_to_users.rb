class AddWeeklySummaryFieldToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :weekly_summary, :boolean, default: false
  end
end
