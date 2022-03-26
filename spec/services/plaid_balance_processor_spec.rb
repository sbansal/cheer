
require 'rails_helper'

RSpec.describe PlaidBalanceProcessor do
  before(:all) do
    @user = create(:user)
  end

  it 'updates account balances' do
    @login_item = create(:login_item, user: @user)
    @bank_account = create(:bank_account, user: @user, login_item: @login_item)
    client = double("client", accounts_balance_get: 'get account balances')
    allow(client).to receive(:accounts_balance_get) { accounts_response }
    allow(PlaidClientCreator).to receive(:call) { client }
    expect(@bank_account.balances.count).to eq 0
    PlaidBalanceProcessor.call(@login_item.plaid_access_token)
    expect(@bank_account.balances.count).to eq 1
    expect(@bank_account.last_balance.available).to eq 2500
    expect(@bank_account.last_balance.current).to eq 2500
    expect(@bank_account.last_balance.limit).to eq 2500
  end

  it 'does not update balance if item is expired' do
    @login_item = create(:login_item, user: @user, expired: true)
    @bank_account = create(:bank_account, user: @user, login_item: @login_item)
    expect(@bank_account.balances.count).to eq 0
    PlaidBalanceProcessor.call(@bank_account.login_item.plaid_access_token)
    expect(@bank_account.balances.count).to eq 0
  end

  it 'marks the item as expired if the link is expired' do
    @login_item = create(:login_item, user: @user)
    @bank_account = create(:bank_account, user: @user, login_item: @login_item)
    client = double("client", accounts_balance_get: 'get account balances')
    allow(client).to receive(:accounts_balance_get).and_raise(api_error)
    allow(PlaidClientCreator).to receive(:call) { client }
    expect(@login_item.expired?).to be false
    PlaidBalanceProcessor.call(@login_item.plaid_access_token)
    @login_item.reload
    expect(@login_item.expired?).to be true
  end

  private

  def accounts_response
    h = {
      accounts: [account_json],
      item: nil,
      request_id: "adlksadja82",
    }
    OpenStruct.new(h)
  end

  def account_json
    OpenStruct.new({
      account_id: @bank_account.plaid_account_id,
      balances: OpenStruct.new({
        available: 2500,
        current: 2500,
        limit: 2500,
        iso_currency_code: "USD",
        unofficial_currency_code: nil
      }),
      mask: "0000",
      name: "Some Checking Account",
      official_name: "Titanium Account",
      subtype: "checking",
      type: "depository"
    })
  end

  def api_error
    Plaid::ApiError.new(
      :code => 400,
      :response_headers => {},
      :response_body =>
        '{
          "display_message": null,
          "error_code": "ITEM_LOGIN_REQUIRED",
          "error_message": "the login details of this item have changed (credentials, MFA, or required user action) and a user login is required to update this information. use Link\'s update mode to restore the item to a good state",
          "error_type": "ITEM_ERROR",
          "request_id": "UatSQfXA8Y6ada",
          "suggested_action": null
        }'
    )
  end
end
