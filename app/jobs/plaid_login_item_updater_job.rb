class PlaidLoginItemUpdaterJob < ApplicationJob
  queue_as :plaid

  def perform(login_item_id)
    Rails.logger.info("[ResqueJob][PlaidLoginItemUpdaterJob] Updating login item with id = #{login_item_id} by fetching data from plaid.")
    PlaidLoginItemUpdater.call(login_item_id)
  end
end
