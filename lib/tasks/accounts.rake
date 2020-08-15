namespace :accounts do
  desc "Backfill account information for users that don't have an account"
  task backfill: :environment do
    User.all.each do |user|
      account = Account.create(name: "#{user.full_name}'s household")
      user.update(account: account)
    end
  end
end
