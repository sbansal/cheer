class NotificationsCreatorJob < ApplicationJob
  queue_as :default

  def perform(transaction_ids)
    NotificationsCreator.call(transaction_ids)
  end
end
