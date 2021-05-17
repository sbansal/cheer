class BackfillStatsData < ActiveRecord::Migration[6.1]
  def up
    Account.all.each do |account|
      StatsCreator.call(account.id, 'ALL')
    end
  end

  def down
    Stat.delete_all
  end
end
