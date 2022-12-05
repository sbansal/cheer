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
    created_at = args[:created_at]
    if created_at
      tx_ids = Transaction.where('created_at > ?', created_at).pluck(:id)
    else
      tx_ids = Transaction.all.pluck(:id)
    end
    Transaction.where(id: tx_ids).each do |tx|
      duplicate_txs = tx.find_duplicates
      puts "Found duplicates for tx id: #{tx.id} - #{duplicate_txs} " unless duplicate_txs.empty?
    end
  end

  desc "Tag duplicate transactions"
  task tag_duplicate_transactions: :environment do |task, args|
    created_at = args[:created_at]
    if created_at
      tx_ids = Transaction.where('created_at > ?', created_at).pluck(:id)
    else
      tx_ids = Transaction.all.pluck(:id)
    end
    duplicates = DuplicateTransactionsProcessor.call(tx_ids)
    if duplicates.count == 0
      puts "No duplicates found"
    else
      puts "Total transactions marked as duplicates: #{duplicates.count}"
    end
  end

  desc "Update all login items"
  task sync_login_items: :environment do |task, args|
    LoginItem.all.each do |login_item|
      if login_item.expired?
        puts "Not updating expired login item #{login_item.id}"
      else
        PlaidLoginItemUpdater.call(login_item.id, false)
      end
    end
  end
end

