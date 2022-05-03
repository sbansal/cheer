require 'rails_helper'

RSpec.describe CashCalculator do
  before('all') do
    @company = create(:company, created_at: 1.year.ago)
    @user = create(:user, company: @company)
    @depository = create(:bank_account, account_type: 'depository', user: @user, current_balance: 5500)
    investment = create(:bank_account, account_type: 'investment', user: @user, current_balance: 5000)
    build_historical_balances(@depository)
  end

  it 'creates historical trend since the beginning of the account creation' do
    company = create(:company, created_at: 1.year.ago)
    user = create(:user, company: company)
    depository = create(:bank_account, account_type: 'depository', user: user, current_balance: 500)
    create(:balance, current: 10500, bank_account: depository, user: user)
    expect(CashCalculator.call(user.company)[:historical_trend_data].keys.first).to eq(1.year.ago.beginning_of_day)
    company = create(:company, created_at: 2.year.ago)
    user = create(:user, company: company)
    depository = create(:bank_account, account_type: 'depository', user: user, current_balance: 500)
    create(:balance, current: 10500, bank_account: depository, user: user)
    expect(CashCalculator.call(user.company)[:historical_trend_data].keys.first).to eq(2.year.ago.beginning_of_day)
  end

  it 'calculates the cash historical trend' do
    historical_trend = CashCalculator.call(@user.company)[:historical_trend_data]
    expect(historical_trend.keys[0]).to eq(1.year.ago.beginning_of_day)
    expect(historical_trend.values[0]).to eq(10500)
    expect(historical_trend.values[1]).to eq(10500)
    expect(historical_trend.keys.last).to eq(Time.zone.now.beginning_of_day)
    expect(historical_trend.values.last).to eq(1000)
  end

  it 'calculates the current value' do
    expect(CashCalculator.call(@user.company)[:current_value]).to eq(5500)
  end

  it 'calculates the cash last change trend' do
    last_change_data = CashCalculator.call(@user.company)[:last_change_data]
    expect(last_change_data).not_to be_nil
    expect(last_change_data).to have_key('all')
    expect(last_change_data).to have_key('weekly')
    expect(last_change_data).to have_key('monthly')
    expect(last_change_data).to have_key('yearly')
    expect(last_change_data).to have_key('quarterly')
    expect(last_change_data['weekly'][:last_change]).to eq(3500)
    expect(last_change_data['weekly'][:last_change_percentage]).to eq(63.64)
    expect(last_change_data['monthly'][:last_change]).to eq(500)
    expect(last_change_data['monthly'][:last_change_percentage]).to eq(9.09)
    expect(last_change_data['quarterly'][:last_change]).to eq(1500)
    expect(last_change_data['quarterly'][:last_change_percentage]).to eq(27.27)
    expect(last_change_data['yearly'][:last_change]).to eq(-5000)
    expect(last_change_data['yearly'][:last_change_percentage]).to eq(-90.91)
    expect(last_change_data['all'][:last_change]).to eq(-5000)
    expect(last_change_data['all'][:last_change_percentage]).to eq(-90.91)
  end

  private

  def build_historical_balances(account)
    Rails.logger.info "build_historical_balances"
    create(:balance, created_at: 1.day.ago, current: 1000, bank_account: account, user: @user)
    create(:balance, created_at: 1.week.ago, current: 2000, bank_account: account, user: @user)
    create(:balance, created_at: 1.month.ago, current: 5000, bank_account: account, user: @user)
    create(:balance, created_at: 3.month.ago, current: 4000, bank_account: account, user: @user)
    create(:balance, created_at: 1.year.ago, current: 10500, bank_account: account, user: @user)
  end
end
