class StripeCustomerCreatorJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    Rails.logger.info("[ResqueJob][StripeCustomerCreatorJob] Creating stripe customer for user id - #{user_id}")
    StripeCustomerCreator.call(user_id)
  end
end
