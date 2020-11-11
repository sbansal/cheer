require 'rails_helper'

RSpec.describe User, type: :model do

  it 'has subscriptions' do
    user = build(:user)
    expect(user.subscriptions.count).to eq 0
  end

  it 'has a last transaction pull date' do
    user = create(:user_with_transactions)
    expect(user.last_transaction_pulled_at).to eq user.transactions.first.occured_at
  end

  it 'has a friendly name' do
    user = build(:user)
    expect(user.friendly_name).to eq 'Joe'
    user = build(:user, full_name: nil)
    expect(user.friendly_name).to eq 'there'
    user = build(:user, full_name: 'Jack')
    expect(user.friendly_name).to eq 'Jack'
  end

  it 'has total assets value' do
    user = build(:user)
    expect(user.total_assets).to eq 0
  end

  it 'has total liability value' do
    user = build(:user)
    expect(user.total_liabilities).to eq 0
  end
end
