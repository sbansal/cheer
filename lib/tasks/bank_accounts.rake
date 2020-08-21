namespace :bank_accounts do
  desc "Generates subscriptions across all the bank accounts"
  task generate_subscriptions: :environment do
    BankAccount.all.each do |bank_account|
      subscriptions = bank_account.create_recurring_transactions
      puts "Generated #{subscriptions.flatten.count} subscriptions for bank_account with id = #{bank_account.id}"
    end
  end
end
