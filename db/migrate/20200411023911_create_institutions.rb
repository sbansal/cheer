class CreateInstitutions < ActiveRecord::Migration[6.0]
  def change
    create_table :institutions do |t|
      t.string :plaid_institution_id
      t.string :name
      t.string :url
      t.string :logo

      t.timestamps
    end
  end
end
