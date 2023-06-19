class AddEnabledProductToCompanies < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :enabled_product, :string, default: 'ALL'
  end
end
