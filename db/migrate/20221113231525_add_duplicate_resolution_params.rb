class AddDuplicateResolutionParams < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :duplicate_resolved_at, :datetime
  end
end
