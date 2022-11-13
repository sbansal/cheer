namespace :plaid do
  desc "Pull transactions for specific dates"
  task :pull_transactions_for_dates, [:start_date, :end_date] => [:environment] do |task, args|
    start_date = args[:start_date]
    end_date = args[:end_date]
    LoginItem.where(expired: false).each do |login_item|
      puts "Queuing transactions pull for dates from #{start_date} to #{end_date} and login_item=#{login_item.to_gid.to_s}"
      RefreshTransactionsJob.perform_later(
        login_item.plaid_access_token,
        login_item.user_id,
        start_date,
        end_date,
      )
    end
  end

  desc "Pull transactions for the last 24 hours"
  task pull_daily_transactions: :environment do |task, args|
    LoginItem.where(expired: false).each do |login_item|
      puts "Queuing transactions pull over the last 24 hour for login_item=#{login_item.to_gid.to_s}"
      start_date = (Date.today - 1.day).iso8601
      end_date = Date.today.iso8601
      RefreshTransactionsJob.perform_later(
        login_item.plaid_access_token,
        login_item.user_id,
        start_date,
        end_date,
      )
    end
  end

  desc "Pull duplicate transactions"
  task pull_duplicate_transactions: :environment do |task, args|
    Transaction.all.each do |tx|
      duplicate_txs = tx.find_duplicates
      puts "Found duplicates for tx id: #{tx.id} - #{duplicate_txs} " unless duplicate_txs.empty?
    end
  end

  desc "Tag duplicate transactions"
  task tag_duplicate_transactions: :environment do |task, args|
    Transaction.all.each do |tx|
      duplicate_txs = tx.find_duplicates
      unless duplicate_txs.empty?
        if duplicate_txs.count > 1
          Rails.logger.error("Multiple duplicate transactions for transaction id #{tx.id} found. Duplicates - #{duplicate_txs}")
        else
          tx.mark_duplicate(duplicate_txs.first)
        end
      end
    end
  end
end

