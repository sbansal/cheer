require 'rails_helper'

RSpec.describe IncomeCalculator do
  before('all') do
    @user = create(:user)
    @category = create(:category, plaid_category_id: Category::INTERNAL_ACCOUNT_TRANSFER_PLAID_ID)
    build_historical_transactions
  end

  it 'calculates the income historical trend' do
    historical_trend_data = IncomeCalculator.call(@user.account)[:historical_trend_data]
    expect(historical_trend_data.keys.count).to eq(13)
    this_month = Date.today.beginning_of_month
    expect(historical_trend_data[this_month]).to eq(100)
    expect(historical_trend_data[this_month - 1.month]).to eq(100)
    expect(historical_trend_data[this_month - 2.month]).to eq(0)
    expect(historical_trend_data[this_month - 3.month]).to eq(100)
    expect(historical_trend_data[this_month - 4.month]).to eq(400)
    expect(historical_trend_data[this_month - 5.month]).to eq(0)
    expect(historical_trend_data[this_month - 1.year]).to eq(500)
  end

  it 'has a current value' do
    expect(IncomeCalculator.call(@user.account)[:current_value]).to eq(1200)
  end

  it 'calculates the income last change trend' do
    expect(IncomeCalculator.call(@user.account)[:last_change_data]).to be_empty
  end

  it 'has value over time data' do
    value_over_time_data = IncomeCalculator.call(@user.account)[:value_over_time_data]
    expect(value_over_time_data[Stat::THIS_MONTH]).to eq(100)
    expect(value_over_time_data[Stat::LAST_MONTH]).to eq(100)
    expect(value_over_time_data[Stat::QUARTERLY]).to eq(300)
    expect(value_over_time_data[Stat::YEARLY]).to eq(1200)
    expect(value_over_time_data[Stat::ALL]).to eq(1200)
  end

  private

  def build_historical_transactions
    create(:transaction, occured_at: Date.today, amount: 100, user: @user)
    create(:transaction, occured_at: Date.today, amount: -100, user: @user, category: @category)
    create(:transaction, occured_at: Date.today, amount: -100, user: @user)
    create(:transaction, occured_at: 1.month.ago, amount: -100, user: @user)
    create(:transaction, occured_at: 3.month.ago, amount: -100, user: @user)
    create(:transaction, occured_at: 4.month.ago, amount: -400, user: @user)
    create(:transaction, occured_at: 1.year.ago, amount: -500, user: @user)
  end
end
