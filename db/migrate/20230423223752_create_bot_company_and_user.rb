class CreateBotCompanyAndUser < ActiveRecord::Migration[7.0]
  def change
    company = Company.create(name: 'PrivatFi Bot Army')
    user = User.new(email: 'privatefi@usecheer.com', company: company, full_name: 'PrivateFi', account_owner: true, password: SecureRandom.hex(8))
    user.skip_confirmation!
    user.save!
  end
end
