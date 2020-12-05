require 'rails_helper'

RSpec.describe BankAccount, type: :model do
  before(:all) do
    @user = create(:user_with_transactions)
    @login_item = create(:login_item, user: @user)
    @category = create(:category)
  end

  describe '#create_accounts_from_json' do
    it 'has 1 bank account' do
      expect {
        BankAccount.create_accounts_from_json([bank_account_json], @login_item.id, @user.id, @login_item.institution_id)
      }.to change { @user.bank_accounts.count }.by(1)
    end

    it 'should not create bank account with same account numbers' do
      BankAccount.create_accounts_from_json([bank_account_json], @login_item.id, @user.id, @login_item.institution_id)
      expect {
        BankAccount.create_accounts_from_json([bank_account_json], @login_item.id, @user.id, @login_item.institution_id)
      }.to change { @user.bank_accounts.count }.by(0)
    end
  end

  describe '#historical_balances' do
    it 'has historical balances' do
      time_in_past = 5.days.ago
      account = create(:bank_account, created_at: time_in_past, user: @user)
      balance1 = create(:balance, created_at: time_in_past, current: 1000, bank_account: account, user: @user)
      balance3 = create(:balance, created_at: time_in_past + 2.day, current: 2000, bank_account: account, user: @user)
      balance5 = create(:balance, created_at: time_in_past + 4.day, current: 4000, bank_account: account, user: @user)
      expect(account.balances.count).to eq 3
      expect(account.historical_balances.count).to eq 6
      expect(account.historical_balances.values.last).to eq balance5.current
    end
  end

  private

  def bank_account_json
    {
      account_id: SecureRandom.hex(32),
      balances: {
        available: nil,
        current: 410,
        limit: 2000,
        iso_currency_code: "USD",
        unofficial_currency_code: nil,
      },
      name: 'Sample Account',
      official_name: 'Sample Account Checking',
      subtype: 'credit card',
      type: 'credit',
      mask: '1111',
    }
  end
end