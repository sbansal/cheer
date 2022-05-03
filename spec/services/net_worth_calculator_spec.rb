require 'rails_helper'

RSpec.describe NetWorthCalculator do
  before('all') do
    @company = create(:company, created_at: 1.year.ago)
    @user = create(:user, company: @company)
    depository = create(:bank_account, account_type: 'depository', user: @user, current_balance: 5500)
    credit = create(:bank_account, account_type: 'credit', user: @user, current_balance: 500)
    build_historical_balances(depository, 2)
    build_historical_balances(credit, 1)
  end

  it 'creates historical trend since the beginning of the account creation' do
    company = create(:company, created_at: 1.year.ago)
    user = create(:user, company: company)
    depository = create(:bank_account, account_type: 'depository', user: user, current_balance: 500)
    create(:balance, current: 10500, bank_account: depository, user: user)
    expect(NetWorthCalculator.call(user.company)[:historical_trend_data].keys.first).to eq(1.year.ago.beginning_of_day)
    company = create(:company, created_at: 2.year.ago)
    user = create(:user, company: company)
    depository = create(:bank_account, account_type: 'credit', user: user, current_balance: 500)
    create(:balance, current: 10500, bank_account: depository, user: user)
    expect(NetWorthCalculator.call(user.company)[:historical_trend_data].keys.first).to eq(2.year.ago.beginning_of_day)
  end

  it 'calculates the net worth historical trend' do
    historical_trend = NetWorthCalculator.call(@user.company)[:historical_trend_data]
    expect(historical_trend.keys[0]).to eq(1.year.ago.beginning_of_day)
    expect(historical_trend.values[0]).to eq(2000)
    expect(historical_trend.values[1]).to eq(2000)
    expect(historical_trend.keys.last).to eq(Time.zone.now.beginning_of_day)
    expect(historical_trend.values.last).to eq(1000)
  end

  it 'calculates the net worth historical trend' do
    expect(NetWorthCalculator.call(@user.company)[:current_value]).to eq(5000)
    last_change_data = NetWorthCalculator.call(@user.company)[:last_change_data]
    expect(last_change_data).not_to be_nil
    expect(last_change_data).to have_key('all')
    expect(last_change_data).to have_key('weekly')
    expect(last_change_data).to have_key('monthly')
    expect(last_change_data).to have_key('yearly')
    expect(last_change_data).to have_key('quarterly')
    expect(last_change_data['weekly'][:last_change]).to eq(3000)
    expect(last_change_data['weekly'][:last_change_percentage]).to eq(60)
    expect(last_change_data['monthly'][:last_change]).to eq(0)
    expect(last_change_data['monthly'][:last_change_percentage]).to eq(0)
    expect(last_change_data['quarterly'][:last_change]).to eq(1000)
    expect(last_change_data['quarterly'][:last_change_percentage]).to eq(20)
    expect(last_change_data['yearly'][:last_change]).to eq(3000)
    expect(last_change_data['yearly'][:last_change_percentage]).to eq(60)
    expect(last_change_data['all'][:last_change]).to eq(3000)
    expect(last_change_data['all'][:last_change_percentage]).to eq(60)
  end

  private

  def build_historical_balances(account, multiplier)
    Rails.logger.info "build_historical_balances"
    create(:balance, created_at: 1.day.ago, current: 1000*multiplier, bank_account: account, user: @user)
    create(:balance, created_at: 1.week.ago, current: 2000*multiplier, bank_account: account, user: @user)
    create(:balance, created_at: 1.month.ago, current: 5000*multiplier, bank_account: account, user: @user)
    create(:balance, created_at: 3.month.ago, current: 4000*multiplier, bank_account: account, user: @user)
    create(:balance, created_at: 1.year.ago, current: 2000*multiplier, bank_account: account, user: @user)
  end
end
