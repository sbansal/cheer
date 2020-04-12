class LoginItem < ApplicationRecord
  has_many :bank_accounts
  belongs_to :user
  belongs_to :institution

  def self.create_from_json(login_item_json, status_json, institution_id, access_token, user_id)
    last_webhook_sent_at = status_json&.last_webhook&.sent_at ? DateTime.parse(status_json&.last_webhook&.sent_at) : nil
    last_successful_transaction_update_at = status_json&.transactions&.last_successful_update ? DateTime.parse(status_json&.transactions&.last_successful_update) : nil
    last_failed_transaction_update_at = status_json&.transactions&.last_failed_update ? DateTime.parse(status_json&.transactions&.last_failed_update) : nil
    consent_expires_at = login_item_json&.consent_expiration_time ? DateTime.parse(login_item_json&.consent_expiration_time) : nil
    create(
      plaid_item_id: login_item_json&.item_id,
      plaid_access_token: access_token,
      institution_id: institution_id,
      consent_expires_at: consent_expires_at,
      error_json: login_item_json&.error,
      last_successful_transaction_update_at: last_successful_transaction_update_at,
      last_failed_transaction_update_at: last_failed_transaction_update_at,
      last_webhook_sent_at: last_webhook_sent_at,
      last_webhook_code_sent: status_json&.last_webhook&.code_sent,
      user_id: user_id,
    )
  end
end
