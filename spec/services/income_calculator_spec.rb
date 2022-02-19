require 'rails_helper'

RSpec.describe IncomeCalculator do
  before('all') do
    @account = create(:account)
    @user = create(:user, account: @account)
    @category = create(:category, plaid_category_id: Category::INTERNAL_ACCOUNT_TRANSFER_PLAID_ID)
    build_historical_transactions
  end

  it 'calculates the income historical trend' do
    historical_trend_data = IncomeCalculator.call(@account)[:historical_trend_data]
    expect(historical_trend_data.keys.count).to eq(732)
    expect(historical_trend_data.keys.first).to eq @account.first_transaction_occured_at
    today = Date.today
    expect(historical_trend_data[today]).to eq(100)
    expect(historical_trend_data[today - 1.month]).to eq(100)
    expect(historical_trend_data[today - 2.month]).to eq(0)
    expect(historical_trend_data[today - 3.month]).to eq(100)
    expect(historical_trend_data[today - 4.month]).to eq(400)
    expect(historical_trend_data[today - 5.month]).to eq(0)
    expect(historical_trend_data[today - 1.year]).to eq(500)
    expect(historical_trend_data[today - 2.year]).to eq(0)
  end

  it 'has a current value' do
    expect(IncomeCalculator.call(@account)[:current_value]).to eq(1200)
  end

  it 'calculates the income last change trend' do
    expect(IncomeCalculator.call(@account)[:last_change_data]).to be_empty
  end

  it 'has value over time data' do
    value_over_time_data = IncomeCalculator.call(@account)[:value_over_time_data]
    expect(value_over_time_data[Stat::THIS_MONTH]).to eq(100)
    expect(value_over_time_data[Stat::LAST_MONTH]).to eq(100)
    expect(value_over_time_data[Stat::QUARTERLY]).to eq(300)
    expect(value_over_time_data[Stat::YEARLY]).to eq(1200)
    expect(value_over_time_data[Stat::ALL]).to eq(1200)
  end

  private

  def build_historical_transactions
    create(:transaction, occured_at: Date.today, amount: 100, user: @user)
    create(:transaction, occured_at: Date.today, amount: 100, user: @user)
    create(:transaction, occured_at: Date.today, amount: -100, user: @user, category: @category)
    create(:transaction, occured_at: Date.today, amount: -100, user: @user)
    create(:transaction, occured_at: 1.month.ago, amount: -100, user: @user)
    create(:transaction, occured_at: 3.month.ago, amount: -100, user: @user)
    create(:transaction, occured_at: 4.month.ago, amount: -400, user: @user)
    create(:transaction, occured_at: 1.year.ago, amount: -500, user: @user)
    create(:transaction, occured_at: 2.year.ago, amount: 500, user: @user)
  end
end
