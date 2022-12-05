require 'rails_helper'

RSpec.describe LoginItem, type: :model do
  let(:token) { 'token' }
  let(:expired_at) { Time.zone.now.iso8601 }
  let(:response) {
    OpenStruct.new(link_token: token, expiration: expired_at)
  }

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
      expect(login_item.link_token_expires_at).to eq expired_at
    end
  end

  describe '#fetch_transactions_after_activation' do
    it 'fetches transactions' do
      login_item = create(:login_item, last_webhook_sent_at: Time.zone.now - 1.month)
      expect(PlaidTransactionsCreator).to receive(:call).with(
        login_item.plaid_access_token,
        login_item.user,
        login_item.last_webhook_sent_at.to_date.iso8601,
        Date.today.iso8601,
      )
      login_item.fetch_transactions
    end
  end

  describe '#should_display_plaid_renew_link?' do
    it 'display the renew link for expired items only' do
      user = create(:user)
      login_item = create(:login_item, expired: true, user: user)
      allow(login_item).to receive(:fetch_link_token) { 'token' }
      expect(login_item.should_display_plaid_renew_link?(user)).to be true
      login_item = create(:login_item, expired: false, user: user)
      expect(login_item.should_display_plaid_renew_link?(user)).to be false
    end

    it 'display the renew link when a plaid link token is present' do
      user = create(:user)
      login_item = create(:login_item, expired: true, user: user)
      allow(login_item).to receive(:fetch_link_token) { nil }
      expect(login_item.should_display_plaid_renew_link?(user)).to be false
    end

    it 'display the renew link to the user that created it' do
      user = create(:user)
      login_item = create(:login_item, expired: true, user: user)
      allow(login_item).to receive(:fetch_link_token) { nil }
      expect(login_item.should_display_plaid_renew_link?(create(:user))).to be false
    end
  end

  describe '#link_token_valid?' do
    it 'returns false if the link token or link token expiry is nil' do
      user = create(:user)
      login_item = create(:login_item, expired: true, link_token: 'token', user: user)
      expect(login_item.link_token_valid?).to be false
      login_item = create(:login_item, expired: true, link_token_expires_at: Time.zone.now, user: user)
      expect(login_item.link_token_valid?).to be false
    end

    it 'returns true if the link token is not expired' do
      user = create(:user)
      login_item = create(:login_item, expired: true, link_token: 'token', link_token_expires_at: Time.zone.now, user: user)
      expect(login_item.link_token_valid?).to be false
    end

    it 'returns false if the link token is expired' do
      user = create(:user)
      login_item = create(:login_item, expired: true, link_token: 'token', link_token_expires_at: Time.zone.now + 1.day, user: user)
      expect(login_item.link_token_valid?).to be true
    end
  end
end
