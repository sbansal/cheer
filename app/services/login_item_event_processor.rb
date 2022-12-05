class LoginItemEventProcessor < EventProcessor

  WEBHOOK_UPDATE_ACKNOWLEDGED_CODE = "WEBHOOK_UPDATE_ACKNOWLEDGED"
  PENDING_EXPIRATION_CODE = "PENDING_EXPIRATION"
  ERROR_CODE = "ERROR"
  USER_PERMISSION_REVOKED = "USER_PERMISSION_REVOKED"
  NEW_ACCOUNTS_AVAILABLE = "NEW_ACCOUNTS_AVAILABLE"

  def initialize(event_code, item_id, metadata={})
    super(event_code, item_id, metadata)
  end

  private

  def process_event
    Rails.logger.tagged("WebhookEvent:LoginItemEvent") do
      case event_code
      when WEBHOOK_UPDATE_ACKNOWLEDGED_CODE
        Rails.logger.info("LoginItem webhook updated to #{metadata['new_webhook_url']}")
        return true
      when PENDING_EXPIRATION_CODE
        expires_at = metadata['consent_expiration_time']
        Rails.logger.info("Item access consent expiring at #{expires_at}")
        login_item.update(consent_expires_at: DateTime.rfc3339(expires_at)&.utc)
      when ERROR_CODE, USER_PERMISSION_REVOKED
        Rails.logger.info("Error with login item. #{metadata['error']}")
        login_item.expire
      when NEW_ACCOUNTS_AVAILABLE
        Rails.logger.info("New accounts are available to be linked.")
        login_item.request_new_account_linking
      else
        Rails.logger.error("Unable to process login item event code = #{event_code}")
        return true
      end
    end
  end
end

