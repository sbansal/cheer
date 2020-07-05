class LoginItemEventProcessor < EventProcessor

  WEBHOOK_UPDATE_ACKNOWLEDGED_CODE = "WEBHOOK_UPDATE_ACKNOWLEDGED"
  PENDING_EXPIRATION_CODE = "PENDING_EXPIRATION"
  ERROR_CODE = "ERROR"

  def initialize(event_code, item_id, metadata={})
    super(event_code, item_id, metadata)
  end

  private

  def process_event
    Rails.logger.tagged("WebhookEvent:LoginItemEvent") do
      case event_code
      when WEBHOOK_UPDATE_ACKNOWLEDGED_CODE
        Rails.logger.info("LoginItem webhook updated to #{metadata['new_webhook_url']}")
      when PENDING_EXPIRATION_CODE
        Rails.logger.info("Item access consent expiring at #{metadata['consent_expiration_time']}")
        # TODO notify the user somehow
      when ERROR
        Rails.logger.info("Error with login item. #{metadata['error']}")
        # TODO notify the user. Have them login again to item.
      else
        Rails.logger.error("Unable to process login item event code = #{event_code}")
        return false
      end
    end
  end
end