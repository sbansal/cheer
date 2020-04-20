class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions do |t|
      t.integer :last_transaction_id
      t.integer :user_id
      t.string :frequency

      t.timestamps
    end
  end
end
