namespace :user do
  desc "this task processes all recurring transactions for all users"
  task :process_subscriptions => :environment do
    User.all.each do |user|
      user.process_recurring_transactions
      puts "Total subscription for user #{user.id} = #{user.subscriptions.count}"
    end
  end
end
