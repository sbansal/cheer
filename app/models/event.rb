class Event < ApplicationRecord
  belongs_to :user

  EVENT_SOURCE_PLAID = 'plaid'
  EVENT_SOURCE_CHEER = 'cheer'
  EVENT_SOURCE_USER = 'user'

  SUMMARY_MAP = {
    CHEER_ACCOUNT_CREATED: 'Cheer account created',
    ACCOUNT_CREATED_MANUALLY: 'New account added',
    ACCOUNT_UPDATED: 'Account updated',
  }

  def self.create_from_params(summary, related_to, metadata, user_id, source)
    global_id = related_to.to_global_id.to_s
    self.create(
      summary: summary,
      global_id: global_id,
      metadata: metadata,
      user_id: user_id,
      source: source
    )
  end
end
