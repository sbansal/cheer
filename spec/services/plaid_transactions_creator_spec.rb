require 'rails_helper'

RSpec.describe PlaidTransactionsCreator do
  before(:all) do
    @user = create(:user_with_transactions)
    @bank_account = create(:bank_account, user: @user)
    @category = create(:category)
    @transaction_id = create(:transaction, user: @user, bank_account: @bank_account, category: @category).plaid_transaction_id
    @start_date = Date.today - 3.month
    @end_date = Date.today
  end

  let(:access_token) { 'access_token' }

  it 'fetches all transactions for login item' do
    client = double("client", transactions_get: 'list of transactions')
    allow(client).to receive(:transactions_get) { create_transactions }
    allow(PlaidClientCreator).to receive(:call) { client }
    expect {
      PlaidTransactionsCreator.call(access_token, @user, @start_date, @end_date)
    }.to change { @user.transactions.count }.by(10)
  end

  it 'updates the account balance' do
    client = double("client", transactions_get: 'list of transactions')
    allow(client).to receive(:transactions_get) { create_transactions }
    allow(PlaidClientCreator).to receive(:call) { client }
    PlaidTransactionsCreator.call(access_token, @user, @start_date, @end_date)
    expect(@bank_account.reload.current_balance).to eq(110)
  end

  it 'creates a new balance entry' do
    client = double("client", transactions_get: 'list of transactions')
    allow(client).to receive(:transactions_get) { create_transactions }
    allow(PlaidClientCreator).to receive(:call) { client }
    expect {
      PlaidTransactionsCreator.call(access_token, @user, @start_date, @end_date)
    }.to change { @bank_account.balances.count }.by(1)
  end

  it 'calls the stat creator job' do
    client = double("client", transactions_get: 'list of transactions')
    allow(client).to receive(:transactions_get) { create_transactions }
    allow(PlaidClientCreator).to receive(:call) { client }
    expect(StatsCreatorJob).to receive(:perform_later)
    PlaidTransactionsCreator.call(access_token, @user, @start_date, @end_date)
  end

  private

  def create_transactions
    transactions = (1..10).map { |i| transaction_json(i) }
    h = {
      accounts: accounts_json,
      transactions: transactions,
      total_transactions: transactions.count
    }
    OpenStruct.new(h)
  end

  def accounts_json
    h = {
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
    }
    [OpenStruct.new(h)]
  end

  def transaction_json(index=0, transaction_id=SecureRandom.hex(32))
    h = {
      account_id: @bank_account.plaid_account_id,
      amount: 200 + index,
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
    OpenStruct.new(h)
  end
end
