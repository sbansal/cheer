namespace :stats do
  desc "Recalculate all the stats for all accounts"
  task recalculate_all: :environment do
    Rails.logger.info("Recalculate ALL stats for all accounts starting now.")
    Company.all.each do |company|
      Rails.logger.info("Recalculate ALL stats for company #{company.id}")
      StatsCreatorJob.perform_later(company.id)
    end
    Rails.logger.info("Recalculate ALL stats for all companies done.")
  end
end
