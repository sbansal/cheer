namespace :accounts do
  desc "Backfill account information for users that don't have an account"
  task backfill: :environment do
    User.all.each do |user|
      if user.account.nil?
        account = Account.create(name: "#{user.full_name}'s household")
        user.update(account: account, account_owner: true)
      end
    end
  end
end
