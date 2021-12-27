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
    client = double("client", transactions_get: 'list of transactions')
    allow(client).to receive(:transactions_get) { create_transactions }
    allow(PlaidClientCreator).to receive(:call) { client }
    expect {
      HistoricalTransactionsCreator.call(access_token, @user, transaction_count)
    }.to change { @user.transactions.count }.by(30)
  end

  it 'updates the account balance' do
    client = double("client", transactions_get: 'list of transactions')
    allow(client).to receive(:transactions_get) { create_transactions }
    allow(PlaidClientCreator).to receive(:call) { client }
    HistoricalTransactionsCreator.call(access_token, @user, transaction_count)
    expect(@bank_account.reload.current_balance).to eq(110)
  end

  it 'creates a new balance entry' do
    client = double("client", transactions_get: 'list of transactions')
    allow(client).to receive(:transactions_get) { create_transactions }
    allow(PlaidClientCreator).to receive(:call) { client }
    expect {
      HistoricalTransactionsCreator.call(access_token, @user, transaction_count)
    }.to change { @bank_account.balances.count }.by(1)
  end

  private

  def create_transactions
    transactions = (1..10).map { |i| transaction_json(i) }
    OpenStruct.new({
      accounts: accounts_json,
      transactions: transactions,
      total_transactions: transactions.count
    })
  end

  def accounts_json
    [
      OpenStruct.new({
        account_id: @bank_account.plaid_account_id,
        balances: OpenStruct.new({
          available: 110,
          current: 110,
          iso_currency_code: "USD",
          limit: nil,
          unofficial_currency_code: nil,
        }),
        mask: @bank_account.mask,
        name: @bank_account.name,
        official_name: @bank_account.official_name,
        subtype: @bank_account.account_subtype,
        type: @bank_account.account_type,
      })
    ]
  end

  def transaction_json(index=0, transaction_id=SecureRandom.hex(32))
    OpenStruct.new({
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
    })
  end
end
