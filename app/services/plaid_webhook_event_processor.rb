class PlaidWebhookEventProcessor < ApplicationService

  JWT_ALG = 'ES256'
  MINUTE_TO_CHECK = 5
  TRANSACTIONS_TYPE = 'TRANSACTIONS'
  ITEM_TYPE = 'ITEM'

  class InvalidWebhookEventError < StandardError; end

  def initialize(plaid_header, raw_body)
    @plaid_header = plaid_header
    @raw_body = raw_body
  end

  def call
    begin
      verify_request
      process_event
      return true
    rescue InvalidWebhookEventError => e
      Rails.logger.error(e)
      return false
    end
  end

  private

  def process_event
    metadata = JSON.parse(@raw_body)
    event_type = metadata['webhook_type']
    event_code = metadata['webhook_code']
    item_id = metadata['item_id']
    if event_type == TRANSACTIONS_TYPE
      TransactionsEventProcessor.call(event_code, item_id, metadata)
    elsif event_type == ITEM_TYPE
      LoginItemEventProcessor.call(event_code, item_id, metadata)
    else
      Rails.logger.tagged("WebhookEvent") {
        Rails.logger.error("Unknown webhook event received with metadata=#{metadata}")
      }
    end
  end

  require 'json/jwt'
  def verify_request
    begin
      token_data = JSON::JWT.decode(@plaid_header, :skip_verification)
      if token_data.alg == JWT_ALG
        key_id = token_data.kid
        client = PlaidClientCreator.call
        response = client.webhooks.get_verification_key(key_id)
        key = JSON::JWK.new(response.key)
        token = JSON::JWT.decode(@plaid_header, key, JWT_ALG.to_sym)
        if webhook_event_outdated?(token['iat'])
          raise InvalidWebhookEventError.new("Rejecting outdated webhook event generated at #{Time.at(token['iat'])}")
        end
        unless webhook_body_authentic?(token['request_body_sha256'])
          raise InvalidWebhookEventError.new("Webhook body could not be verified. Rejecting the webhook.")
        end
      else
        raise InvalidWebhookEventError.new("Unsupported JWT Algo = #{header['alg']}. Rejecting the webhook.")
      end
    rescue => e
      raise InvalidWebhookEventError.new(e)
    end
  end

  def webhook_event_outdated?(iat)
    (Time.at(iat) - Time.now) > MINUTE_TO_CHECK * 60
  end

  require 'digest'
  def webhook_body_authentic?(body_sha)
    Digest::SHA2.new(256).hexdigest(@raw_body) == body_sha
  end
end