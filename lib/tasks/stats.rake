namespace :stats do
  desc "Recalculate all the stats for all accounts"
  task recalculate_all: :environment do
    Rails.logger.info("Recalculate ALL stats for all accounts starting now.")
    Account.all.each do |account|
      Rails.logger.info("Recalculate ALL stats for account #{account.id}")
      StatsCreatorJob.perform_later(account.id)
    end
    Rails.logger.info("Recalculate ALL stats for all accounts done.")
  end
end
