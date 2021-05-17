require 'rails_helper'

RSpec.describe LoginItem, type: :model do
  let(:token) { 'token' }
  let(:expired_at) { Time.zone.now.iso8601 }
  let(:response) { { 'link_token' => token, 'expiration' =>  expired_at } }

  describe '#expired' do
    it 'expires the login item' do
      login_item = build(:login_item)
      expect(login_item.expired?).to be false
      login_item.expire
      expect(login_item.expired?).to be true
    end
  end

  describe '#activate' do
    it 'activates the login item' do
      login_item = build(:login_item, expired: true, expired_at: Time.zone.now,
        link_token: nil, link_token_expires_at: Time.zone.now)
      login_item.activate
      expect(login_item.expired?).to be false
      expect(login_item.expired_at).to be nil
      expect(login_item.link_token).to be nil
      expect(login_item.link_token_expires_at).to be nil
    end
  end

  describe '#fetch_link_token' do
    it 'generates a link token' do
      allow(PlaidLinkTokenCreator).to receive(:call) { response }
      login_item = build(:login_item)
      expect(login_item.fetch_link_token).to eq token
      expect(login_item.link_token_expires_at).to eq DateTime.parse(expired_at)
    end
  end

  describe '#fetch_transactions_after_activation' do
    it 'fetches transactions' do
      login_item = create(:login_item, last_webhook_sent_at: Time.zone.now - 1.month)
      expect(RefreshTransactionsJob).to receive(:perform_later).with(
        login_item.plaid_access_token,
        login_item.user_id,
        login_item.last_webhook_sent_at.to_date.iso8601,
        Date.today.iso8601,
      )
      login_item.enqueue_transaction_fetch
    end
  end
end
