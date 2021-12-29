class LoginItem < ApplicationRecord
  has_many :bank_accounts, dependent: :destroy
  belongs_to :user
  belongs_to :institution

  def self.create_from_json(login_item_json, status_json, institution_id, access_token, user_id)
    last_webhook_sent_at = status_json&.last_webhook&.sent_at
    last_successful_transaction_update_at = status_json&.transactions&.last_successful_update
    last_failed_transaction_update_at = status_json&.transactions&.last_failed_update
    consent_expires_at = login_item_json&.consent_expiration_time
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

  def status
    expired? ? "inactive" : "active"
  end

  def transactions_count
    bank_accounts.includes(:transactions).inject(0) { |sum, account| sum + account.transactions.count }
  end

  def register_webhook
    client = PlaidClientCreator.call
    request = Plaid::ItemWebhookUpdateRequest.new(
      {
        access_token: plaid_access_token,
        webhook: Rails.application.credentials[:login_item_webhook],
      }
    )
    response = client.item_webhook_update(request)
    Rails.logger.info("Webhook updated for login_item=#{self.inspect} and response=#{response}")
  end

  def transactions_history_period
    min_date = bank_accounts.map { |account| account.transactions&.last&.occured_at }.compact.min
    max_date = bank_accounts.map { |account| account.transactions&.first&.occured_at }.compact.max
    return [min_date, max_date]
  end

  def expire
    update(expired: true, expired_at: Time.zone.now )
    GenericMailer.login_item_expired_notification(self.user_id, self.id).deliver_later
  end

  def activate
    update(expired: false, expired_at: nil, link_token: nil, link_token_expires_at: nil)
    GenericMailer.login_item_activated_notification(self.user_id, self.id).deliver_later
  end

  def enqueue_transaction_fetch
    last_transaction_date = transactions_history_period[1] || self.created_at.to_date
    last_webhook_date = self.last_webhook_sent_at&.to_date || self.created_at.to_date
    start_date = [last_webhook_date, last_transaction_date].min
    RefreshTransactionsJob.perform_later(self.plaid_access_token, self.user_id, start_date.iso8601, Date.today.iso8601)
  end

  def fetch_link_token
    begin
      response = PlaidLinkTokenCreator.call(self.user_id, self.plaid_access_token, true)
      link_token = response['link_token']
      update(
        link_token_expires_at: DateTime.parse(response['expiration']),
        link_token: link_token,
      )
    rescue => e
      Rails.logger.error(e)
    end
    link_token
  end

  def should_display_plaid_renew_link?(current_user)
    expired? && self.user == current_user && fetch_link_token.present?
  end
end
