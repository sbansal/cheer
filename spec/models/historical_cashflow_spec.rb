require 'rails_helper'

RSpec.describe HistoricalCashflow, type: :model do
  before(:all) do 
    @user = create(:user)
    @bank_account = create(:bank_account, user: @user)
    @category = create(:category)
    (1..5).each do |n|
      occured_at = (Date.today.beginning_of_month - n.month)
      create(:transaction, description: "tx#{n}", user: @user, bank_account: @bank_account, category: @category, occured_at: occured_at)
      create(:transaction, description: "tx#{n}", amount: -10, user: @user, bank_account: @bank_account, category: @category, occured_at: occured_at)
    end
  end

  it 'calculates historical cashflow' do
    pending
    start_date = Time.zone.now.beginning_of_month - 1.year
    end_date = Time.zone.now
    hist_cashflow = HistoricalCashflow.new(start_date, end_date, @user.transactions)
    expect(hist_cashflow.monthly_trends.count).to eq 5
    expect(hist_cashflow.monthly_trends.first[:date]).to eq (Date.today.beginning_of_month - 1.month).to_date
    expect(hist_cashflow.monthly_trends.last[:date]).to eq (Date.today.beginning_of_month - 5.month).to_date
  end
  
  after(:all) do
    Category.destroy_all
    BankAccount.destroy_all
    Transaction.destroy_all
    User.destroy_all
  end
  
  private
   
  def create_recurring_transactions(description, frequency)
    freq = case frequency
      when 'daily' then 1.day
      when 'weekly' then 1.week
      when 'monthly' then 1.month
      when 'quarterly' then 3.month
      when 'yearly' then 1.year
    end
    (1..5).each do |n|
      create(
        :transaction,
        description: description,
        occured_at: (n*freq).ago,
        user: @user,
        bank_account: @bank_account,
        category: @category
      )
    end
  end
end