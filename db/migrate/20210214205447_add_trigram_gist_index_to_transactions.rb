class AddTrigramGistIndexToTransactions < ActiveRecord::Migration[6.1]
  def self.up
    execute "CREATE INDEX IF NOT EXISTS trgm_description_indx ON transactions USING gist (description gist_trgm_ops);"
  end

  def self.down
    execute "DROP INDEX IF EXISTS trgm_description_indx "
  end
end
