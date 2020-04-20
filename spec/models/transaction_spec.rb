require 'rails_helper'

RSpec.describe Transaction, type: :model do
  before(:all) do 
    @user = create(:user)
    @bank_account = create(:bank_account, user: @user)
  end
  
  it 'has 0 recurring transaction' do
    p @bank_account.inspect
    create(:transaction, description: 'tx1', user: @user, bank_account: @bank_account)
    create(:transaction, description: 'tx2', user: @user, bank_account: @bank_account)
    byebug
    expect(@user.transactions.count).to eq 2
    hash = @user.process_recurring_transactions
    expect(@user.subscriptions.count).to eq 0
  end
  
  it 'has 5 recurring transaction' do
    p @bank_account.inspect
    create_recurring_transactions('monthly-sub', 'monthly', @user, @bank_account)
    create_recurring_transactions('yearly-sub', 'yearly', @user, @bank_account)
    create_recurring_transactions('daily-sub', 'daily', @user, @bank_account)
    create_recurring_transactions('weekly-sub', 'weekly', @user, @bank_account)
    create_recurring_transactions('quarterly-sub', 'quarterly', @user, @bank_account)
    expect(@user.transactions.count).to eq 25
    hash = @user.process_recurring_transactions
    puts hash
    expect(@user.subscriptions.count).to eq 5
  end

  def create_recurring_transactions(description, frequency, user, account)
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
        user: user,
        bank_account: account
      )
    end
  end
end
