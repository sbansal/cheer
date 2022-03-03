require 'rails_helper'

RSpec.describe EssentialExpensesCalculator do
  before('all') do
    @account = create(:account)
    @user = create(:user, account: @account)
    @category = create(:category, plaid_category_id: Category::CC_PAYMENT_PLAID_ID)
    build_historical_transactions
  end

  it 'calculates the income historical trend' do
    historical_trend_data = EssentialExpensesCalculator.call(@user.account)[:historical_trend_data]
    expect(historical_trend_data.keys.count).to eq(366)
    today = Date.today
    expect(historical_trend_data[today]).to eq(100)
    expect(historical_trend_data[today - 1.month]).to eq(300)
    expect(historical_trend_data[today - 2.month]).to eq(0)
    expect(historical_trend_data[today - 3.month]).to eq(300)
    expect(historical_trend_data[today - 4.month]).to eq(800)
    expect(historical_trend_data[today - 5.month]).to eq(0)
    expect(historical_trend_data[today - 1.year]).to eq(500)
  end

  it 'has a current value' do
    expect(EssentialExpensesCalculator.call(@account)[:current_value]).to eq(2000)
  end

  it 'calculates the income last change trend' do
    expect(EssentialExpensesCalculator.call(@account)[:last_change_data]).to be_empty
  end

  it 'has value over time data' do
    value_over_time_data = EssentialExpensesCalculator.call(@account)[:value_over_time_data]
    expect(value_over_time_data[Stat::THIS_MONTH]).to eq(100)
    expect(value_over_time_data[Stat::LAST_MONTH]).to eq(300)
    expect(value_over_time_data[Stat::QUARTERLY]).to eq(700)
    expect(value_over_time_data[Stat::YEARLY]).to eq(2000)
    expect(value_over_time_data[Stat::ALL]).to eq(2000)
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
    create(:transaction, occured_at: Date.today - 3.month, amount: 100, user: @user)
    create(:transaction, occured_at: Date.today - 3.month, amount: 100, user: @user)
    create(:transaction, occured_at: Date.today - 3.month, amount: 100, user: @user)
    create(:transaction, occured_at: Date.today - 3.month, amount: 100, user: @user, essential: false)
    create(:transaction, occured_at: Date.today - 4.month, amount: 400, user: @user)
    create(:transaction, occured_at: Date.today - 4.month, amount: 400, user: @user)
    create(:transaction, occured_at: Date.today - 4.month, amount: 400, user: @user, essential: false)
    create(:transaction, occured_at: Date.today - 4.month, amount: 400, user: @user, essential: false)
    create(:transaction, occured_at: Date.today - 1.year, amount: 500, user: @user)
    create(:transaction, occured_at: Date.today - 1.year, amount: 500, user: @user, essential: false)
    create(:transaction, occured_at: Date.today - 1.year, amount: 500, user: @user, essential: false)
    create(:transaction, occured_at: Date.today - 1.year, amount: 500, user: @user, essential: false)
  end
end
