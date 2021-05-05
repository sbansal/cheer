class BackfillHistoricalTrends < ActiveRecord::Migration[6.1]
  def up
    Account.all.each do |account|
      StatsCreator.call(account.id, 'ALL')
    end
  end

  def down
    Stat.update_all(historical_trend_data: nil)
  end
end
