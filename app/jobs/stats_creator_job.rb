class StatsCreatorJob < ApplicationJob
  queue_as :stats

  def perform(company_id, stat_name='ALL')
    StatsCreator.call(company_id, stat_name)
  end
end
