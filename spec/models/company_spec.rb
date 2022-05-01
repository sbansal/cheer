require 'rails_helper'

RSpec.describe Company, type: :model do

  it 'has users' do
    company = create(:company_with_users)
    expect(company.users.count).to be > 0
  end

  it 'has net worth' do
    company = create(:company)
    shubham = create(:user, company: company)
    deepti = create(:user, company: company)
    create(:bank_account_with_balances, account_type: 'depository', user: shubham)
    expect(company.net_worth).to eq 1000
    create(:bank_account_with_balances, account_type: 'loan', user: shubham)
    expect(company.net_worth).to eq 0
    create(:bank_account_with_balances, account_type: 'investment', user: deepti)
    expect(company.net_worth).to eq 1000
    create(:bank_account_with_balances, account_type: 'credit', user: deepti)
    expect(company.net_worth).to eq 0
  end

  it 'has cash and non cash assets' do
    company = create(:company)
    shubham = create(:user, company: company)
    deepti = create(:user, company: company)
    create(:bank_account_with_balances, account_type: 'depository', user: shubham)
    expect(company.total_cash_assets).to eq 1000
    expect(company.total_non_cash_assets).to eq 0
    create(:bank_account_with_balances, account_type: 'loan', user: shubham)
    expect(company.total_cash_assets).to eq 1000
    expect(company.total_non_cash_assets).to eq 0
    create(:bank_account_with_balances, account_type: 'investment', user: shubham)
    expect(company.total_cash_assets).to eq 1000
    expect(company.total_non_cash_assets).to eq 1000
    create(:bank_account_with_balances, account_type: 'investment', account_subtype: 'brokerage', user: deepti)
    expect(company.total_cash_assets).to eq 2000
    expect(company.total_non_cash_assets).to eq 1000
    create(:bank_account_with_balances, account_type: 'cash', user: deepti)
    expect(company.total_cash_assets).to eq 3000
    expect(company.total_non_cash_assets).to eq 1000
  end

  it 'has assets' do
    company = create(:company)
    shubham = create(:user, company: company)
    deepti = create(:user, company: company)
    create(:bank_account_with_balances, account_type: 'depository', user: shubham)
    expect(company.total_assets).to eq 1000
    create(:bank_account_with_balances, account_type: 'loan', user: shubham)
    expect(company.total_assets).to eq 1000
    create(:bank_account_with_balances, account_type: 'investment', account_subtype: 'brokerage', user: deepti)
    expect(company.total_assets).to eq 2000
    create(:bank_account_with_balances, account_type: 'credit', user: deepti)
    expect(company.total_assets).to eq 2000
  end

  it 'has liabilities' do
    company = create(:company)
    shubham = create(:user, company: company)
    deepti = create(:user, company: company)
    create(:bank_account_with_balances, account_type: 'depository', user: shubham)
    expect(company.total_liabilities).to eq 0
    create(:bank_account_with_balances, account_type: 'loan', user: shubham)
    expect(company.total_liabilities).to eq 1000
    create(:bank_account_with_balances, account_type: 'investment', user: deepti)
    expect(company.total_liabilities).to eq 1000
    create(:bank_account_with_balances, account_type: 'credit', user: deepti)
    expect(company.total_liabilities).to eq 2000
  end

  it 'has assets_trend' do
    time_in_past = 5.days.ago
    company = create(:company, created_at: time_in_past)
    shubham = create(:user, company: company)
    deepti = create(:user, company: company)
    sba = create(:bank_account, created_at: time_in_past, account_type: 'investment', user: shubham)
    sba_balance1 = create(:balance, created_at: time_in_past, current: 1000, bank_account: sba, user: shubham)
    sba_balance3 = create(:balance, created_at: time_in_past + 2.day, current: 2000, bank_account: sba, user: shubham)
    dba = create(:bank_account, created_at: time_in_past, account_type: 'investment', user: deepti)
    dba_balance1 = create(:balance, created_at: time_in_past, current: 1000, bank_account: dba, user: shubham)
    dba_balance3 = create(:balance, created_at: time_in_past + 2.day, current: 2000, bank_account: dba, user: shubham)
    expect(company.assets_trend.count).to eq 6
  end

  it 'gives the first_transaction_occured_at' do
    time_in_past = 5.days.ago
    company = create(:company, created_at: time_in_past)
    shubham = create(:user, company: company)
    deepti = create(:user, company: company)
    sba = create(:bank_account, created_at: time_in_past, account_type: 'investment', user: shubham)
    create(:transaction, occured_at: time_in_past, amount: 100, user: shubham, bank_account: sba)
    expect(company.first_transaction_occured_at).to eq time_in_past.to_date
    time_in_past = 10.days.ago
    create(:transaction, occured_at: time_in_past, amount: 100, user: shubham, bank_account: sba)
    expect(company.first_transaction_occured_at).to eq time_in_past.to_date
  end
end
