require 'rails_helper'

RSpec.describe NonEssentialExpensesCalculator do
  before('all') do
    @company = create(:company)
    @user = create(:user, company: @company)
    @category = create(:category, plaid_category_id: Category::CC_PAYMENT_PLAID_ID)
    build_historical_transactions
  end

  it 'calculates the income historical trend' do
    historical_trend_data = NonEssentialExpensesCalculator.call(@company)[:historical_trend_data]
    expect(historical_trend_data.keys.count).to eq(366)
    today = Date.today
    expect(historical_trend_data[today]).to eq(100)
    expect(historical_trend_data[today - 1.month]).to eq(0)
    expect(historical_trend_data[today - 2.month]).to eq(0)
    expect(historical_trend_data[today - 3.month]).to eq(0)
    expect(historical_trend_data[today - 4.month]).to eq(0)
    expect(historical_trend_data[today - 5.month]).to eq(0)
    expect(historical_trend_data[today - 1.year]).to eq(500)
  end

  it 'has a current value' do
    expect(NonEssentialExpensesCalculator.call(@user.company)[:current_value]).to eq(600)
  end

  it 'calculates the income last change trend' do
    expect(NonEssentialExpensesCalculator.call(@user.company)[:last_change_data]).to be_empty
  end

  it 'has value over time data' do
    value_over_time_data = NonEssentialExpensesCalculator.call(@user.company)[:value_over_time_data]
    expect(value_over_time_data[Stat::THIS_MONTH]).to eq(100)
    expect(value_over_time_data[Stat::LAST_MONTH]).to eq(0)
    expect(value_over_time_data[Stat::QUARTERLY]).to eq(100)
    expect(value_over_time_data[Stat::YEARLY]).to eq(600)
    expect(value_over_time_data[Stat::ALL]).to eq(600)
  end

  private

  def build_historical_transactions
    create(:transaction, occured_at: Date.today, amount: -100, user: @user)
    create(:transaction, occured_at: Date.today, amount: 100, user: @user, category: @category)
    create(:transaction, occured_at: Date.today, amount: 100, user: @user, essential: false)
    create(:transaction, occured_at: 1.month.ago, amount: 100, user: @user)
    create(:transaction, occured_at: 3.month.ago, amount: 100, user: @user)
    create(:transaction, occured_at: 4.month.ago, amount: 400, user: @user)
    create(:transaction, occured_at: 1.year.ago, amount: 500, user: @user)
    create(:transaction, occured_at: 1.year.ago, amount: 500, user: @user, essential: false)
  end
end
