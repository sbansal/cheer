require 'rails_helper'

RSpec.describe Account, type: :model do

  it 'has users' do
    account = create(:account_with_users)
    expect(account.users.count).to be > 0
  end

  it 'has net worth' do
    account = create(:account)
    shubham = create(:user, account: account)
    deepti = create(:user, account: account)
    create(:bank_account_with_balances, account_type: 'depository', user: shubham)
    expect(account.net_worth).to eq 1000
    create(:bank_account_with_balances, account_type: 'loan', user: shubham)
    expect(account.net_worth).to eq 0
    create(:bank_account_with_balances, account_type: 'investment', user: deepti)
    expect(account.net_worth).to eq 1000
    create(:bank_account_with_balances, account_type: 'credit', user: deepti)
    expect(account.net_worth).to eq 0
  end

  it 'has assets' do
    account = create(:account)
    shubham = create(:user, account: account)
    deepti = create(:user, account: account)
    create(:bank_account_with_balances, account_type: 'depository', user: shubham)
    expect(account.total_assets).to eq 1000
    create(:bank_account_with_balances, account_type: 'loan', user: shubham)
    expect(account.total_assets).to eq 1000
    create(:bank_account_with_balances, account_type: 'investment', user: deepti)
    expect(account.total_assets).to eq 2000
    create(:bank_account_with_balances, account_type: 'credit', user: deepti)
    expect(account.total_assets).to eq 2000
  end

  it 'has liabilities' do
    account = create(:account)
    shubham = create(:user, account: account)
    deepti = create(:user, account: account)
    create(:bank_account_with_balances, account_type: 'depository', user: shubham)
    expect(account.total_liabilities).to eq 0
    create(:bank_account_with_balances, account_type: 'loan', user: shubham)
    expect(account.total_liabilities).to eq 1000
    create(:bank_account_with_balances, account_type: 'investment', user: deepti)
    expect(account.total_liabilities).to eq 1000
    create(:bank_account_with_balances, account_type: 'credit', user: deepti)
    expect(account.total_liabilities).to eq 2000
  end
end
