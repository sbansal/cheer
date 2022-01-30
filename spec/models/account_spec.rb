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

  it 'has cash and non cash assets' do
    account = create(:account)
    shubham = create(:user, account: account)
    deepti = create(:user, account: account)
    create(:bank_account_with_balances, account_type: 'depository', user: shubham)
    expect(account.total_cash_assets).to eq 1000
    expect(account.total_non_cash_assets).to eq 0
    create(:bank_account_with_balances, account_type: 'loan', user: shubham)
    expect(account.total_cash_assets).to eq 1000
    expect(account.total_non_cash_assets).to eq 0
    create(:bank_account_with_balances, account_type: 'investment', user: shubham)
    expect(account.total_cash_assets).to eq 1000
    expect(account.total_non_cash_assets).to eq 1000
    create(:bank_account_with_balances, account_type: 'investment', account_subtype: 'brokerage', user: deepti)
    expect(account.total_cash_assets).to eq 2000
    expect(account.total_non_cash_assets).to eq 1000
    create(:bank_account_with_balances, account_type: 'cash', user: deepti)
    expect(account.total_cash_assets).to eq 3000
    expect(account.total_non_cash_assets).to eq 1000
  end

  it 'has assets' do
    account = create(:account)
    shubham = create(:user, account: account)
    deepti = create(:user, account: account)
    create(:bank_account_with_balances, account_type: 'depository', user: shubham)
    expect(account.total_assets).to eq 1000
    create(:bank_account_with_balances, account_type: 'loan', user: shubham)
    expect(account.total_assets).to eq 1000
    create(:bank_account_with_balances, account_type: 'investment', account_subtype: 'brokerage', user: deepti)
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

  it 'has assets_trend' do
    time_in_past = 5.days.ago
    account = create(:account, created_at: time_in_past)
    shubham = create(:user, account: account)
    deepti = create(:user, account: account)
    sba = create(:bank_account, created_at: time_in_past, account_type: 'investment', user: shubham)
    sba_balance1 = create(:balance, created_at: time_in_past, current: 1000, bank_account: sba, user: shubham)
    sba_balance3 = create(:balance, created_at: time_in_past + 2.day, current: 2000, bank_account: sba, user: shubham)
    dba = create(:bank_account, created_at: time_in_past, account_type: 'investment', user: deepti)
    dba_balance1 = create(:balance, created_at: time_in_past, current: 1000, bank_account: dba, user: shubham)
    dba_balance3 = create(:balance, created_at: time_in_past + 2.day, current: 2000, bank_account: dba, user: shubham)
    expect(account.assets_trend.count).to eq 6
  end
end
