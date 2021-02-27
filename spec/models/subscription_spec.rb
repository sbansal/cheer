require 'rails_helper'

RSpec.describe Subscription, type: :model do
  before(:all) do
    @user = create(:user_with_transactions)
    @bank_account = create(:bank_account, user: @user)
    @category = create(:category)
    @transaction = create(:transaction, occured_at: 2.month.ago, bank_account: @bank_account, user: @user)
  end

  describe '#active?' do
    it 'is active if last transaction within last month' do
      subscription = create(:subscription, frequency: 'monthly', active: true)
      expect(subscription.active?).to eq true
    end

    it 'is not active if last transaction within last month' do
      subscription = create(:subscription, frequency: 'monthly', last_transaction: @transaction)
      expect(subscription.active?).to eq false
    end
  end

  describe '#all_transactions' do
    it 'returns all transactions for the subscriptions' do
      transaction1 = create(:transaction, occured_at: 2.month.ago, bank_account: @bank_account, user: @user, description: 'tx1', category: @category)
      transaction2 = create(:transaction, occured_at: 1.month.ago, bank_account: @bank_account, user: @user, description: 'tx1', category: @category)
      subscription = create(:subscription, description: 'tx1', bank_account: @bank_account, last_transaction: transaction2, user: @user)
      expect(subscription.all_transactions.size).to eq 2
    end
  end
end