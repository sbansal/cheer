require 'rails_helper'

RSpec.describe InvestmentsCalculator do
  before('all') do
    @user = create(:user)
    @depository = create(:bank_account, account_type: 'depository', user: @user, current_balance: 5500)
    @investment = create(:bank_account, account_type: 'investment', user: @user, current_balance: 5000)
    build_historical_balances(@investment)
  end

  it 'calculates the investments historical trend' do
    historical_trend = InvestmentsCalculator.call(@user.account)[:historical_trend_data]
    expect(historical_trend.count).to eq(366)
    expect(historical_trend.keys[0]).to eq(1.year.ago.beginning_of_day)
    expect(historical_trend.values[0]).to eq(10500)
    expect(historical_trend.values[1]).to eq(10500)
    expect(historical_trend.keys.last).to eq(Time.zone.now.beginning_of_day)
    expect(historical_trend.values.last).to eq(1000)
    create(:balance, created_at: 2.year.ago, current: 10500, bank_account: @depository, user: @user)
    expect(InvestmentsCalculator.call(@user.account)[:historical_trend_data].count).to eq(366)
  end

  it 'calculates current value' do
    expect(InvestmentsCalculator.call(@user.account)[:current_value]).to eq(5000)
  end

  it 'calculates the net worth historical trend' do
    last_change_data = InvestmentsCalculator.call(@user.account)[:last_change_data]
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
    expect(last_change_data['yearly'][:last_change]).to eq(-5500)
    expect(last_change_data['yearly'][:last_change_percentage]).to eq(-110)
    expect(last_change_data['all'][:last_change]).to eq(-5500)
    expect(last_change_data['all'][:last_change_percentage]).to eq(-110)
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
