class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.string :summary
      t.string :global_id
      t.jsonb :metadata
      t.integer :user_id
      t.string :source

      t.timestamps
    end
  end
end
