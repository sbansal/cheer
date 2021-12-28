require 'rails_helper'

RSpec.describe "PlaidLinkTokenCreator" do
  let(:user) { create(:user) }

  it 'creates a link token' do
    response = PlaidLinkTokenCreator.call(user.id)
    expect(response.link_token).not_to be_nil
    expect(response.expiration).not_to be_nil
    expect(response.request_id).not_to be_nil
  end

  it 'creates a link token in update mode' do
    response = PlaidLinkTokenCreator.call(user.id, create_plaid_sandbox_link_and_fetch_access_token, true)
    expect(response.link_token).not_to be_nil
    expect(response.expiration).not_to be_nil
    expect(response.request_id).not_to be_nil
  end

  it 'throws an error with invalid access token' do
    expect {
      PlaidLinkTokenCreator.call(user.id, 'access_token', true)
    }.to raise_exception(Plaid::ApiError)
  end
end