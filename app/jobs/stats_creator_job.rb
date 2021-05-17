class StatsCreatorJob < ApplicationJob
  queue_as :stats

  def perform(account_id, stat_name='ALL')
    StatsCreator.call(account_id, stat_name)
  end
end
