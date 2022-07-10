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
      Rails.logger.error(e.backtrace.join("\n"))
      return false
    end
  end

  private

  def process_event
    begin
      metadata = JSON.parse(@raw_body)
      event_type = metadata['webhook_type']
      event_code = metadata['webhook_code']
      item_id = metadata['item_id']
      if event_type == TRANSACTIONS_TYPE
        TransactionsEventProcessor.call(event_code, item_id, metadata)
      elsif event_type == ITEM_TYPE
        LoginItemEventProcessor.call(event_code, item_id, metadata)
      else
        Rails.logger.error("[WebhookEvent] Unknown webhook event received with metadata=#{metadata}")
      end
    rescue => e
      Rails.logger.error(e)
      raise InvalidWebhookEventError.new(e)
    end
  end

  require 'json/jwt'
  def verify_request
    begin
      Rails.logger.info("[WebhookEvent] Verifying the Webhook request.")
      token_data = JSON::JWT.decode(@plaid_header, :skip_verification)
      if token_data.alg == JWT_ALG
        key_id = token_data.kid
        client = PlaidClientCreator.call
        request = Plaid::WebhookVerificationKeyGetRequest.new({ key_id: key_id })
        response = client.webhook_verification_key_get(request)
        key = JSON::JWK.new(response.key)
        token = JSON::JWT.decode(@plaid_header, key, JWT_ALG.to_sym)
        if webhook_event_outdated?(token['iat'])
          raise InvalidWebhookEventError.new("[PlaidWebhookEventProcessor] Rejecting outdated webhook event generated at #{Time.at(token['iat'])}")
        end
        unless webhook_body_authentic?(token['request_body_sha256'])
          raise InvalidWebhookEventError.new("[PlaidWebhookEventProcessor] Webhook body could not be verified. Rejecting the webhook.")
        end
        Rails.logger.info("[WebhookEvent] Verification complete for the webhook request.")
      else
        raise InvalidWebhookEventError.new("[PlaidWebhookEventProcessor] Unsupported JWT Algo = #{token_data.alg}. Rejecting the webhook.")
      end
    rescue => e
      Rails.logger.tagged("WebhookEvent") {
        Rails.logger.error(e)
        Rails.logger.error(e.backtrace.join("\n"))
      }
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