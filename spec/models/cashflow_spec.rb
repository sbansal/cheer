require 'rails_helper'

RSpec.describe Cashflow, type: :model do
  before(:all) do
    @user = create(:user)
    @bank_account = create(:bank_account, user: @user)
    @category = create(:category)
    (1..5).each { |n| create(:transaction, description: "tx#{n}", user: @user, bank_account: @bank_account, category: @category)}
    (6..10).each { |n| create(:transaction, description: "tx#{n}", amount: -10, user: @user, bank_account: @bank_account, category: @category)}
  end

  it 'calculates cashflow' do
    cashflow = Cashflow.new(Time.zone.now.beginning_of_month, Time.zone.now, @user.transactions)
    expect(cashflow.total_money_out).to eq 125
    expect(cashflow.total_money_in).to eq -50
  end

  it 'calculates time period' do
    cashflow = Cashflow.new(Time.zone.now.beginning_of_month, Time.zone.now, @user.transactions)
    expect(cashflow.time_period).to eq Time.zone.now.strftime('%b %Y')
    cashflow = Cashflow.new(Time.zone.now.beginning_of_month - 1.month, Time.zone.now, @user.transactions)
    expect(cashflow.time_period).to eq "Since #{cashflow.start_date.strftime('%b %-d, %Y')}"
  end

  after(:all) do
    Category.delete_all
    BankAccount.delete_all
    Transaction.delete_all
    User.delete_all
  end
end