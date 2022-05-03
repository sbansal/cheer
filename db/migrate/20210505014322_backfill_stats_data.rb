class BackfillStatsData < ActiveRecord::Migration[6.1]
  def up
    Company.all.each do |company|
      StatsCreator.call(company.id, 'ALL')
    end
  end

  def down
    Stat.delete_all
  end
end
