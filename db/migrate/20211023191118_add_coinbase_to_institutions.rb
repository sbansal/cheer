class AddCoinbaseToInstitutions < ActiveRecord::Migration[6.1]
  def up
    Institution.create(
      name: 'Coinbase',
      url: 'https://coinbase.com',
    )
  end

  def down
    Institution.find_by_name('Coinbase').delete
  end
end
