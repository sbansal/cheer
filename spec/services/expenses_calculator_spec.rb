require 'rails_helper'

RSpec.describe ExpensesCalculator do
  before('all') do
    @company = create(:company)
    @user = create(:user, company: @company)
    @category = create(:category, plaid_category_id: Category::CC_PAYMENT_PLAID_ID)
    build_historical_transactions
  end

  it 'calculates the income historical trend' do
    historical_trend_data = ExpensesCalculator.call(@company)[:historical_trend_data]
    expect(historical_trend_data.keys.count).to eq(366)
    expect(historical_trend_data.keys.first).to eq @company.first_transaction_occured_at.beginning_of_day
    today = Date.today
    expect(historical_trend_data[today - 2.year]).to eq(nil)
    expect(historical_trend_data[today]).to eq(200)
    expect(historical_trend_data[today - 1.month]).to eq(400)
    expect(historical_trend_data[today - 2.month]).to eq(0)
    expect(historical_trend_data[today - 3.month]).to eq(400)
    expect(historical_trend_data[today - 4.month]).to eq(1200)
    expect(historical_trend_data[today - 5.month]).to eq(0)
    expect(historical_trend_data[today - 1.year]).to eq(2000)

  end

  it 'has a current value' do
    expect(ExpensesCalculator.call(@company)[:current_value]).to eq(4200)
  end

  it 'calculates the income last change trend' do
    expect(ExpensesCalculator.call(@company)[:last_change_data]).to be_empty
  end

  it 'has value over time data' do
    value_over_time_data = ExpensesCalculator.call(@company)[:value_over_time_data]
    expect(value_over_time_data[Stat::THIS_MONTH]).to eq(200)
    expect(value_over_time_data[Stat::LAST_MONTH]).to eq(400)
    expect(value_over_time_data[Stat::QUARTERLY]).to eq(1000)
    expect(value_over_time_data[Stat::YEARLY]).to eq(4200)
    expect(value_over_time_data[Stat::ALL]).to eq(4200)
  end

  private

  def build_historical_transactions
    create(:transaction, occured_at: Date.today, amount: -100, user: @user)
    create(:transaction, occured_at: Date.today, amount: 100, user: @user, category: @category)
    create(:transaction, occured_at: Date.today, amount: 100, user: @user, essential: false)
    create(:transaction, occured_at: Date.today, amount: 100, user: @user)
    create(:transaction, occured_at: Date.today - 1.month, amount: 100, user: @user)
    create(:transaction, occured_at: Date.today - 1.month, amount: 100, user: @user)
    create(:transaction, occured_at: Date.today - 1.month, amount: 100, user: @user)
    create(:transaction, occured_at: Date.today - 1.month, amount: 100, user: @user, essential: false)
    create(:transaction, occured_at: Date.today - 3.months, amount: 100, user: @user)
    create(:transaction, occured_at: Date.today - 3.months, amount: 100, user: @user)
    create(:transaction, occured_at: Date.today - 3.months, amount: 200, user: @user)
    create(:transaction, occured_at: Date.today - 3.months, amount: -100, user: @user, essential: false)
    create(:transaction, occured_at: Date.today - 4.months, amount: 400, user: @user)
    create(:transaction, occured_at: Date.today - 4.months, amount: 400, user: @user)
    create(:transaction, occured_at: Date.today - 4.months, amount: 400, user: @user, essential: false)
    create(:transaction, occured_at: Date.today - 4.months, amount: -400, user: @user, essential: false)
    create(:transaction, occured_at: Date.today - 1.year, amount: 500, user: @user)
    create(:transaction, occured_at: Date.today - 1.year, amount: 500, user: @user, essential: false)
    create(:transaction, occured_at: Date.today - 1.year, amount: 1000, user: @user, essential: false)
    create(:transaction, occured_at: Date.today - 1.year, amount: -500, user: @user, essential: false)
  end
end
