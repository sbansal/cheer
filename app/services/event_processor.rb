class EventProcessor < ApplicationService
  attr_reader :login_item, :event_code, :metadata

  def initialize(event_code, item_id, metadata={})
    Rails.logger.tagged("WebhookEvent") { 
      Rails.logger.info("Processing event with code=#{event_code}, item_id=#{item_id}, metadata=#{metadata}")
    }
    @event_code = event_code
    @metadata = metadata
    @login_item = load_login_item(item_id)
  end

  def call
    process_event
    mark_event_received
  end

  private

  def load_login_item(item_id)
    LoginItem.find_by(plaid_item_id: item_id)
  end
  
  def mark_event_received
    login_item.update(
      last_webhook_sent_at: Time.zone.now,
      last_webhook_code_sent: event_code
    )
  end
  
  def process_event
    Rails.logger.tagged("event") { 
      Rails.logger.error("Unsupported operation and event processing.")
    }
    false
  end
end