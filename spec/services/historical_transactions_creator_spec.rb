require 'spec_helper'

RSpec.describe 'HistoricalTransactionsCreator' do
  let(:access_token) { 'access_token' }
  let(:user) { create(:user) }
  let(:transaction_count) { 100 }
  let(:client) { double('client') }

  subject(:htc) do
    HistoricalTransactionsCreator.call(access_token, user, transaction_count)
  end

  it 'fetches all transactions for login item' do
    puts htc
  end
end