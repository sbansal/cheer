require 'rails_helper'

RSpec.describe LoginItem, type: :model do
  let(:token) { 'token' }
  let(:expired_at) { Time.zone.now.iso8601 }
  let(:response) { { 'public_token' => token, 'expiration' =>  expired_at } }

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
        public_token: nil, public_token_expired_at: Time.zone.now)
      login_item.activate
      expect(login_item.expired?).to be false
      expect(login_item.expired_at).to be nil
      expect(login_item.public_token).to be nil
      expect(login_item.public_token_expired_at).to be nil
    end
  end

  describe '#fetch_public_token' do
    it 'generates a public token' do
      allow(PlaidPublicTokenCreator).to receive(:call) { response }
      login_item = build(:login_item)
      expect(login_item.fetch_public_token).to eq token
      expect(login_item.public_token_expired_at).to eq DateTime.parse(expired_at)
    end
  end
end
