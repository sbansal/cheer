require 'rails_helper'

RSpec.describe PlaidLoginItemUpdater do
  before(:all) do
    @user = create(:user_with_transactions)
    @login_item = create(:login_item, user: @user)
    @bank_account = create(:bank_account, user: @user, login_item: @login_item)
    @category = create(:category)
  end
  let(:time) { Time.zone.now }

  let(:access_token) { 'access_token' }

  it 'updates the login item' do
    client = double("client", item_get: 'items')
    allow(client).to receive(:item_get) { login_item_response }
    allow(client).to receive(:accounts_get) { accounts_json(@bank_account) }
    allow(PlaidClientCreator).to receive(:call) { client }
    PlaidLoginItemUpdater.call(@login_item.id, false)
    @login_item = @login_item.reload
    expect(@login_item.consent_expires_at).to eq nil
    expect(@login_item.last_successful_transaction_update_at).to eq time
    expect(@login_item.bank_accounts.count).to eq 1
    expect(@bank_account.reload.archived?).to eq false
  end

  it 'updates the accounts data of the login item' do
    client = double("client", item_get: 'items')
    bank_account = build(:bank_account, mask: '2222', name: 'Chase Ultimate', official_name: 'Chase Ultimate')
    allow(client).to receive(:item_get) { login_item_response }
    allow(client).to receive(:accounts_get) { accounts_json(bank_account) }
    allow(PlaidClientCreator).to receive(:call) { client }
    PlaidLoginItemUpdater.call(@login_item.id, false)
    @login_item = @login_item.reload
    expect(@login_item.consent_expires_at).to eq nil
    expect(@login_item.last_successful_transaction_update_at).to eq time
    expect(@login_item.bank_accounts.count).to eq 2
    expect(@bank_account.reload.archived?).to eq true
  end

  it 'fetches the transaction data of the login item' do
    client = double("client", item_get: 'items')
    bank_account = build(:bank_account, mask: '2222', name: 'Chase Ultimate', official_name: 'Chase Ultimate')
    allow(client).to receive(:item_get) { login_item_response }
    allow(client).to receive(:accounts_get) { accounts_json(@bank_account) }
    allow(PlaidClientCreator).to receive(:call) { client }
    expect(PlaidTransactionsCreator).to receive(:call)
    PlaidLoginItemUpdater.call(@login_item.id, true)
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

  def accounts_json(bank_account)
    h = {
      accounts: [
        OpenStruct.new({
          account_id: bank_account.plaid_account_id,
          balances: OpenStruct.new({
            available: 110,
            current: 110,
            iso_currency_code: "USD",
            limit: nil,
            unofficial_currency_code: nil,
            }),
          mask: bank_account.mask,
          name: bank_account.name,
          official_name: bank_account.official_name,
          subtype: bank_account.account_subtype,
          type: bank_account.account_type,
        })
      ]
    }
    OpenStruct.new(h)
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

  def login_item_response(code='DEFAULT_UPDATE')
    h = {
      item: OpenStruct.new({
        item_id: @access_token,
        institution_id: @bank_account.institution.plaid_institution_id,
        consent_expiration_time: nil,
      }),
      status: OpenStruct.new({
        transactions: OpenStruct.new({
         last_successful_update: time,
         last_failed_update: time,
         last_webhook: {
           sent_at: time,
           code_sent: code
         }
        })
      })
   }
   OpenStruct.new(h)
  end
end
