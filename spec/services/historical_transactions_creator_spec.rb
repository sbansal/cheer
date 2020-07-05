require 'rails_helper'

RSpec.describe HistoricalTransactionsCreator do
  before(:all) do
    @user = create(:user_with_transactions)
    @bank_account = create(:bank_account, user: @user)
    @category = create(:category)
    @transaction_id = create(:transaction, user: @user, bank_account: @bank_account, category: @category).plaid_transaction_id
  end

  let(:access_token) { 'access_token' }
  let(:user) { create(:user) }
  let(:transaction_count) { 30 }


  it 'fetches all transactions for login item' do
    client = double("client", transactions: double('transactions', get: 'list of transactions'))
    allow(client.transactions).to receive(:get) { create_transactions }
    allow(PlaidClientCreator).to receive(:call) { client }
    expect {
      HistoricalTransactionsCreator.call(access_token, @user, transaction_count)
    }.to change { @user.transactions.count }.by(30)
  end

  private

  def create_transactions
    transactions = (1..10).map { |i| transaction_json(i) }
    {
      transactions: transactions,
      total_transactions: transactions.count
    }
  end

  def transaction_json(index=0, transaction_id=SecureRandom.hex(32))
    {
      account_id: @bank_account.plaid_account_id,
      amount: 200,
      category_id: @category.plaid_category_id,
      date: Date.today.iso8601,
      iso_currency_code: "USD",
      name: "tx-#{index}",
      payment_channel:"online",
      payment_meta: nil,
      pending: false,
      transaction_id: transaction_id,
      transaction_type: "place"
    }
  end
end
