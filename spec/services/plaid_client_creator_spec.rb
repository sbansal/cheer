require 'rails_helper'

RSpec.describe PlaidClientCreator do
  it 'initializes the plaid client' do
    expect { PlaidClientCreator.call }.not_to raise_exception
    expect(PlaidClientCreator.call).to be_an_instance_of(Plaid::PlaidApi)
  end

  it 'has the correct configuration' do
    client = PlaidClientCreator.call
    expect(client.api_client.config.api_key['Plaid-Version']).to eq '2020-09-14'
    expect(client.api_client.config.api_key['PLAID-CLIENT-ID']).not_to be_nil
    expect(client.api_client.config.api_key['PLAID-SECRET']).not_to be_nil
  end
end
