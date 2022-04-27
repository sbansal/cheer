namespace :companies do
  desc "Backfill account information for users that don't have an account"
  task backfill: :environment do
    User.all.each do |user|
      if user.company.nil?
        company = Company.create(name: "#{user.full_name}'s household")
        user.update(company: company, account_owner: true)
      end
    end
  end
end
