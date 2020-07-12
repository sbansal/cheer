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
end
