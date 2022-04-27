class BackfillValueOverTimeData < ActiveRecord::Migration[6.1]
  def up
    Company.all.each do |company|
      StatsCreator.call(company.id, 'ALL')
    end
  end

  def down
    Stat.update_all(value_over_time_data: nil)
  end
end
