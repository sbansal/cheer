require 'rails_helper'

RSpec.describe Transaction, type: :model do
  before(:all) do
    @user = create(:user_with_transactions)
    @bank_account = create(:bank_account, user: @user)
    @category = create(:category)
    @transaction_id = create(:transaction, user: @user, bank_account: @bank_account, category: @category).plaid_transaction_id
  end

  it 'has 0 recurring transaction' do
    expect(@user.transactions.count).to eq 11
    hash = @user.process_recurring_transactions
    expect(@user.subscriptions.count).to eq 0
  end

  # it 'has 5 recurring transaction' do
  #   create_recurring_transactions('monthly-sub', 'monthly')
  #   create_recurring_transactions('yearly-sub', 'yearly')
  #   create_recurring_transactions('daily-sub', 'daily')
  #   create_recurring_transactions('weekly-sub', 'weekly')
  #   create_recurring_transactions('quarterly-sub', 'quarterly')
  #   hash = @user.process_recurring_transactions
  #   expect(@user.subscriptions.count).to eq 5
  # end

  describe "#create_transactions_from_json" do
    it 'creates transactions' do
      tx = transaction_json(@bank_account.plaid_account_id, @category.plaid_category_id, SecureRandom.hex(32))
      expect {
        Transaction.create_transactions_from_json([tx], @user.id)
      }.to change { @user.transactions.count }.by(1)
    end

    it 'upserts transactions' do
      tx_id = SecureRandom.hex(32)
      tx_1 = transaction_json(@bank_account.plaid_account_id, @category.plaid_category_id, tx_id)
      tx_2 = tx_1.merge(amount: 50, transaction_id: @transaction_id)
      tx_3 = transaction_json(@bank_account.plaid_account_id, @category.plaid_category_id, SecureRandom.hex(32))
      expect {
        Transaction.create_transactions_from_json([tx_1, tx_2, tx_3], @user.id)
      }.to change { @user.transactions.count }.by(2)
      updated_tx = Transaction.find_by_plaid_transaction_id(tx_id)
      expect(updated_tx.amount).to eq 200
    end

    it 'updates transactions' do
      tx = transaction_json(@bank_account.plaid_account_id, @category.plaid_category_id, @transaction_id)
      tx = tx.merge(name: 'netflix.com')
      expect {
        Transaction.create_transactions_from_json([tx], @user.id)
      }.to change { @user.transactions.count }.by(0)
      expect(Transaction.find_by_plaid_transaction_id(@transaction_id).custom_description).to eq 'netflix.com'
    end

    it 'does not create transaction with invalid account' do
      tx = transaction_json(@bank_account.plaid_account_id, @category.plaid_category_id, SecureRandom.hex(32))
      invalid_bank_tx = tx.merge(account_id: 10000000)
      expect {
        Transaction.create_transactions_from_json([invalid_bank_tx], @user.id)
      }.to change { @user.transactions.count }.by(0)
    end

    it 'does not create transaction with invalid category' do
      tx = transaction_json(@bank_account.plaid_account_id, @category.plaid_category_id, SecureRandom.hex(32))
      invalid_bank_tx = tx.merge(category_id: 12345678)
      expect {
        Transaction.create_transactions_from_json([invalid_bank_tx], @user.id)
      }.to change { @user.transactions.count }.by(0)
    end
  end

  after(:all) do
    Category.destroy_all
    BankAccount.destroy_all
    Transaction.destroy_all
    User.destroy_all
  end

  private

  def create_recurring_transactions(description, frequency)
    freq = case frequency
      when 'daily' then 1.day
      when 'weekly' then 1.week
      when 'monthly' then 1.month
      when 'quarterly' then 3.month
      when 'yearly' then 1.year
    end
    (1..5).each do |n|
      create(
        :transaction,
        description: description,
        occured_at: (n*freq).ago,
        user: @user,
        bank_account: @bank_account,
        category: @category
      )
    end
  end

  def transaction_json(bank_account_id, category_id, transaction_id)
    {
      account_id: bank_account_id,
      amount: 200,
      category_id: category_id,
      date: Date.today.iso8601,
      iso_currency_code: "USD",
      name: "Amazon.com",
      payment_channel:"online",
      payment_meta: nil,
      pending: false,
      transaction_id: transaction_id,
      transaction_type: "place"
    }
  end
end
